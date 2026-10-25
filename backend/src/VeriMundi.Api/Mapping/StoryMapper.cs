using VeriMundi.Api.Contracts;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;

namespace VeriMundi.Api.Mapping;

public static class StoryMapper
{
    public static StoryDto ToDto(StoryCluster story, bool markDemo = false)
    {
        var sources = story.ArticleLinks
            .OrderBy(l => l.AddedAt)
            .Select(l =>
            {
                var article = l.Article!;
                var source = article.Source!;
                return new SourceArticleDto(
                    Id: article.Id.ToString(),
                    Name: source.Name,
                    ArticleUrl: article.CanonicalUrl,
                    PublisherUrl: source.WebsiteUrl ?? $"https://{source.CanonicalDomain}",
                    CountryCode: article.SourceCountryCode ?? source.CountryCode ?? "",
                    LanguageCode: article.Language,
                    PublicationType: source.SourceType.ToString(),
                    IsLocalSource: l.SourceCoverageClass == CoverageClass.Local,
                    PublishedAt: article.PublishedAt ?? article.DiscoveredAt,
                    Author: article.Author,
                    CredibilityStatus: "established",
                    Headline: article.Headline,
                    CoverageLevel: l.SourceCoverageClass.ToString().ToLowerInvariant());
            })
            .ToList();

        var confirmed = story.Claims
            .Where(c => c.Status == ClaimStatus.Confirmed)
            .Select(c => new ConfirmedFactDto(
                c.Text,
                c.Evidence.Where(e => e.Supports).Select(e => e.ArticleId.ToString()).DefaultIfEmpty(sources.FirstOrDefault()?.Id ?? c.Id.ToString()).ToList()))
            .ToList();

        if (confirmed.Count == 0 && !string.IsNullOrWhiteSpace(story.ShortSummary) && sources.Count > 0)
        {
            confirmed.Add(new ConfirmedFactDto(
                story.ShortSummary,
                sources.Take(2).Select(s => s.Id).ToList()));
        }

        var disputed = story.Claims
            .Where(c => c.Status == ClaimStatus.Disputed)
            .Select(c => new DisputedClaimDto(
                c.Text,
                c.Evidence.Where(e => e.Supports).Select(e => e.ArticleId.ToString()).ToList(),
                c.Evidence.Where(e => e.Disputes).Select(e => e.ArticleId.ToString()).ToList()))
            .ToList();

        return new StoryDto(
            Id: story.Id.ToString(),
            Headline: story.CanonicalHeadline,
            ShortSummary: story.ShortSummary,
            FullSummary: string.IsNullOrWhiteSpace(story.FullSummary) ? story.ShortSummary : story.FullSummary,
            WhyItMatters: story.WhyItMatters,
            CountryCodes: story.AffectedCountryCodes.Count > 0 ? story.AffectedCountryCodes : [story.PrimaryCountryCode],
            PrimaryCountryCode: story.PrimaryCountryCode,
            Region: story.Region,
            Category: ToCamel(story.Category.ToString()),
            Latitude: story.Latitude,
            Longitude: story.Longitude,
            FirstPublishedAt: story.FirstPublishedAt,
            LastUpdatedAt: story.LastUpdatedAt,
            Severity: ToCamel(story.Severity.ToString()),
            SeverityReason: story.SeverityReason,
            Tone: ToCamel(story.Tone.ToString()),
            VerificationStatus: ToCamel(story.VerificationStatus.ToString()),
            ConfidenceScore: story.ConfidenceScore,
            LocalSourceCount: story.LocalSourceCount,
            RegionalSourceCount: story.RegionalSourceCount,
            InternationalSourceCount: story.InternationalSourceCount,
            IndependentSourceCount: story.IndependentSourceCount,
            UnderreportedScore: story.UnderreportedScore,
            UnderreportedReason: story.UnderreportedReason,
            PositiveImpactScore: story.PositiveImpactScore,
            RankingReason: story.RankingReason,
            SourceArticles: sources,
            ConfirmedFacts: confirmed,
            DisputedClaims: disputed,
            Uncertainties: story.Uncertainties,
            IsDemoContent: markDemo,
            CorrectionNotice: story.CorrectionNotice,
            CorrectedAt: story.CorrectedAt);
    }

    public static CountryDto ToCountryDto(Country country, IEnumerable<StoryCluster> stories)
    {
        var list = stories.ToList();
        var severity = list.Count == 0
            ? Severity.General
            : list.Max(s => s.Severity);
        return new CountryDto(
            country.Code,
            country.Name,
            country.Region,
            country.Latitude,
            country.Longitude,
            ToCamel(severity.ToString()),
            list.Count,
            list.Count(s => s.Tone == Tone.Positive),
            list.Count == 0 ? DateTimeOffset.UtcNow : list.Max(s => s.LastUpdatedAt));
    }

    private static string ToCamel(string value) =>
        string.IsNullOrEmpty(value) ? value : char.ToLowerInvariant(value[0]) + value[1..];
}
