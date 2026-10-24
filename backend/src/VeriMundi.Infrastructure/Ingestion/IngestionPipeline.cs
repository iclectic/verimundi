using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Clustering;
using VeriMundi.Application.Scoring;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Infrastructure.Ingestion;

public sealed class IngestionPipeline(
    VeriMundiDbContext db,
    IEnumerable<INewsProvider> providers,
    StoryClusteringService clustering,
    IAiSynthesisService ai,
    ILogger<IngestionPipeline> logger)
{
    public async Task<IngestionResult> RunAsync(CancellationToken cancellationToken = default)
    {
        var ingested = 0;
        var clustered = 0;

        foreach (var provider in providers)
        {
            IReadOnlyList<Application.Ingestion.IngestedArticle> batch;
            try
            {
                batch = await provider.FetchLatestAsync(new IngestionRequest(MaxItems: 100), cancellationToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Provider {Provider} failed", provider.Name);
                continue;
            }

            foreach (var item in batch)
            {
                var source = await ResolveSourceAsync(item, cancellationToken);
                if (source is null || source.LicenceStatus is LicenceStatus.Rejected or LicenceStatus.Restricted)
                {
                    continue;
                }

                if (source.LicenceStatus != LicenceStatus.Approved && provider.Name != "fixture")
                {
                    continue;
                }

                var canonicalKey = clustering.CanonicalUrlKey(item.CanonicalUrl);
                var canonicalHash = clustering.Hash(canonicalKey);
                var existing = await db.Articles.FirstOrDefaultAsync(a => a.CanonicalHash == canonicalHash, cancellationToken);
                if (existing is not null)
                {
                    continue;
                }

                var contentHash = clustering.Hash($"{item.Headline}|{item.PermittedExcerpt}|{canonicalKey}");
                var article = new Article
                {
                    SourceId = source.Id,
                    CanonicalUrl = item.CanonicalUrl,
                    Headline = item.Headline.Trim(),
                    PermittedExcerpt = item.PermittedExcerpt,
                    Author = item.Author,
                    PublishedAt = item.PublishedAt,
                    Language = item.Language,
                    SourceCountryCode = item.SourceCountryCode ?? source.CountryCode,
                    IngestionProvider = item.ProviderName,
                    ContentHash = contentHash,
                    CanonicalHash = canonicalHash,
                    ProcessingStatus = ProcessingStatus.Normalised,
                    ImageUrl = source.ContentUsageStatus == ContentUsageStatus.Prohibited ? null : item.ImageUrl
                };
                db.Articles.Add(article);
                await db.SaveChangesAsync(cancellationToken);
                ingested++;

                var story = await AttachOrCreateClusterAsync(article, source, item.RegionHint, item.CategoryHint, cancellationToken);
                clustered++;

                await SynthesiseIfNeededAsync(story, cancellationToken);
            }
        }

        return new IngestionResult(ingested, clustered);
    }

    private async Task<Source?> ResolveSourceAsync(
        Application.Ingestion.IngestedArticle item,
        CancellationToken cancellationToken)
    {
        var domain = item.SourceDomain.Trim().ToLowerInvariant();
        var source = await db.Sources.FirstOrDefaultAsync(s => s.CanonicalDomain == domain, cancellationToken);
        if (source is not null)
        {
            return source;
        }

        // Auto-propose unknown domains; never auto-approve.
        source = new Source
        {
            Name = domain,
            CanonicalDomain = domain,
            CountryCode = item.SourceCountryCode,
            Region = item.RegionHint,
            LicenceStatus = LicenceStatus.Proposed,
            ContentUsageStatus = ContentUsageStatus.HeadlineAndLink,
            Enabled = false
        };
        db.Sources.Add(source);
        await db.SaveChangesAsync(cancellationToken);
        return source;
    }

    private async Task<StoryCluster> AttachOrCreateClusterAsync(
        Article article,
        Source source,
        string? regionHint,
        string? categoryHint,
        CancellationToken cancellationToken)
    {
        var country = article.SourceCountryCode ?? source.CountryCode ?? "ZZ";
        var region = regionHint ?? source.Region ?? "Unknown";
        var key = clustering.ClusterKey(article, region);
        var normalised = clustering.NormaliseHeadline(article.Headline);

        var candidates = await db.Stories
            .Include(s => s.ArticleLinks)
            .ThenInclude(l => l.Article!)
            .ThenInclude(a => a.Source)
            .Where(s => s.Status == StoryStatus.Active && s.PrimaryCountryCode == country)
            .OrderByDescending(s => s.LastUpdatedAt)
            .Take(40)
            .ToListAsync(cancellationToken);

        var match = candidates.FirstOrDefault(s =>
            clustering.NormaliseHeadline(s.CanonicalHeadline) == normalised ||
            clustering.Hash($"{normalised}|{(article.PublishedAt ?? article.DiscoveredAt):yyyy-MM-dd}|{country}|{region}") == key);

        var coverage = clustering.InferCoverageClass(source, country);

        if (match is null)
        {
            var geo = await db.Countries.AsNoTracking()
                .FirstOrDefaultAsync(c => c.Code == country, cancellationToken);
            match = new StoryCluster
            {
                CanonicalHeadline = article.Headline,
                PrimaryCountryCode = country,
                AffectedCountryCodes = [country],
                Region = region,
                Category = ParseCategory(categoryHint),
                Latitude = geo?.Latitude,
                Longitude = geo?.Longitude,
                FirstPublishedAt = article.PublishedAt ?? article.DiscoveredAt,
                LastUpdatedAt = DateTimeOffset.UtcNow,
                Severity = Severity.Developing,
                SeverityReason = "Awaiting synthesis.",
                SeverityConfidence = 0.4,
                SeverityUpdatedAt = DateTimeOffset.UtcNow,
                Tone = Tone.Neutral,
                VerificationStatus = VerificationStatus.Developing,
                ConfidenceScore = 0.4
            };
            db.Stories.Add(match);
            await db.SaveChangesAsync(cancellationToken);
        }

        if (match.ArticleLinks.All(l => l.ArticleId != article.Id))
        {
            db.StoryArticleLinks.Add(new StoryArticleLink
            {
                StoryId = match.Id,
                ArticleId = article.Id,
                SimilarityScore = 1.0,
                SourceCoverageClass = coverage
            });
            await db.SaveChangesAsync(cancellationToken);
        }

        await RefreshCoverageCountsAsync(match.Id, cancellationToken);
        return (await db.Stories.Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
            .FirstAsync(s => s.Id == match.Id, cancellationToken));
    }

    private async Task RefreshCoverageCountsAsync(Guid storyId, CancellationToken cancellationToken)
    {
        var story = await db.Stories
            .Include(s => s.ArticleLinks)
            .ThenInclude(l => l.Article!)
            .ThenInclude(a => a.Source)
            .FirstAsync(s => s.Id == storyId, cancellationToken);

        story.LocalSourceCount = story.ArticleLinks.Count(l => l.SourceCoverageClass == CoverageClass.Local);
        story.RegionalSourceCount = story.ArticleLinks.Count(l => l.SourceCoverageClass == CoverageClass.Regional);
        story.InternationalSourceCount = story.ArticleLinks.Count(l => l.SourceCoverageClass == CoverageClass.International);
        var sources = story.ArticleLinks.Select(l => l.Article!.Source!).Where(s => s is not null).Cast<Source>();
        story.IndependentSourceCount = clustering.CountIndependentSources(sources);
        story.LastUpdatedAt = DateTimeOffset.UtcNow;

        var (score, reason) = UnderreportedScorer.Calculate(
            story.Severity,
            story.LocalSourceCount,
            story.RegionalSourceCount,
            story.InternationalSourceCount,
            story.IndependentSourceCount,
            story.ConfidenceScore);
        story.UnderreportedScore = score;
        story.UnderreportedReason = reason;
        story.RankingReason = WorldPulseRanker.RankingReason(story, WorldPulseRanker.ImportanceScore(story));

        if (story.Tone == Tone.Positive)
        {
            story.PositiveImpactScore = Math.Clamp(40 + story.IndependentSourceCount * 8, 0, 100);
        }

        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task SynthesiseIfNeededAsync(StoryCluster story, CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(story.ShortSummary) && !story.InsufficientEvidence)
        {
            return;
        }

        var links = await db.StoryArticleLinks
            .Include(l => l.Article!)
            .ThenInclude(a => a.Source)
            .Where(l => l.StoryId == story.Id)
            .ToListAsync(cancellationToken);

        var evidence = links.Select(l => new AiSourceEvidence(
            l.ArticleId,
            l.Article!.SourceId.ToString(),
            l.Article.Source?.Name ?? l.Article.SourceId.ToString(),
            l.Article.Headline,
            l.Article.PermittedExcerpt,
            l.SourceCoverageClass.ToString().ToLowerInvariant())).ToList();

        var result = await ai.SynthesiseAsync(
            new AiSynthesisRequest(story.Id, story.CanonicalHeadline, evidence),
            cancellationToken);

        story.ShortSummary = result.Summary;
        story.FullSummary = result.Summary;
        story.WhyItMatters = result.WhyItMatters;
        story.Uncertainties = result.Uncertainties.ToList();
        story.ConfidenceScore = result.ConfidenceScore;
        story.InsufficientEvidence = result.InsufficientEvidence;
        story.VerificationStatus = result.InsufficientEvidence
            ? VerificationStatus.InsufficientEvidence
            : VerificationStatus.Developing;
        story.Tone = Enum.TryParse<Tone>(result.Tone, true, out var tone) ? tone : story.Tone;
        story.Severity = Enum.TryParse<Severity>(result.Severity, true, out var severity) ? severity : story.Severity;
        story.SeverityReason = result.SeverityReason;
        story.SeverityConfidence = result.ConfidenceScore;
        story.SeverityUpdatedAt = DateTimeOffset.UtcNow;
        story.GeneratedAt = DateTimeOffset.UtcNow;

        foreach (var fact in result.ConfirmedFacts)
        {
            var claim = new Claim
            {
                StoryId = story.Id,
                Text = fact.Text,
                Status = ClaimStatus.Confirmed,
                Confidence = result.ConfidenceScore
            };
            db.Claims.Add(claim);
        }

        var (score, reason) = UnderreportedScorer.Calculate(
            story.Severity,
            story.LocalSourceCount,
            story.RegionalSourceCount,
            story.InternationalSourceCount,
            story.IndependentSourceCount,
            story.ConfidenceScore);
        story.UnderreportedScore = score;
        story.UnderreportedReason = reason;
        if (story.Tone == Tone.Positive)
        {
            story.PositiveImpactScore = Math.Clamp(45 + story.IndependentSourceCount * 7, 0, 100);
        }

        await db.SaveChangesAsync(cancellationToken);
    }

    private static StoryCategory ParseCategory(string? hint)
    {
        if (string.IsNullOrWhiteSpace(hint))
        {
            return StoryCategory.Other;
        }

        return Enum.TryParse<StoryCategory>(hint.Replace(" ", string.Empty), true, out var category)
            ? category
            : StoryCategory.Other;
    }
}

public sealed record IngestionResult(int ArticlesIngested, int ClusterOperations);
