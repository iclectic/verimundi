using System.ServiceModel.Syndication;
using System.Xml;
using Microsoft.Extensions.Logging;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Ingestion;
using VeriMundi.Domain;
using VeriMundi.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// Fetches headlines/links from approved RSS feeds only. Does not download article bodies.
/// </summary>
public sealed class RssNewsProvider(
    VeriMundiDbContext db,
    IHttpClientFactory httpClientFactory,
    ILogger<RssNewsProvider> logger) : INewsProvider
{
    public string Name => "rss";

    public async Task<IReadOnlyList<IngestedArticle>> FetchLatestAsync(
        IngestionRequest request,
        CancellationToken cancellationToken = default)
    {
        var sources = await db.Sources
            .AsNoTracking()
            .Where(s => s.Enabled &&
                        s.LicenceStatus == LicenceStatus.Approved &&
                        s.FeedUrl != null)
            .ToListAsync(cancellationToken);

        var results = new List<IngestedArticle>();
        var client = httpClientFactory.CreateClient("ingestion");

        foreach (var source in sources)
        {
            try
            {
                await using var stream = await client.GetStreamAsync(source.FeedUrl!, cancellationToken);
                using var reader = XmlReader.Create(stream);
                var feed = SyndicationFeed.Load(reader);
                foreach (var item in feed.Items.Take(request.MaxItems))
                {
                    var url = item.Links.FirstOrDefault()?.Uri?.ToString();
                    if (string.IsNullOrWhiteSpace(url) || string.IsNullOrWhiteSpace(item.Title?.Text))
                    {
                        continue;
                    }

                    results.Add(new IngestedArticle(
                        ProviderName: Name,
                        SourceDomain: source.CanonicalDomain,
                        CanonicalUrl: url,
                        Headline: item.Title.Text.Trim(),
                        PermittedExcerpt: Truncate(item.Summary?.Text, 400),
                        Author: item.Authors.FirstOrDefault()?.Name,
                        PublishedAt: item.PublishDate == DateTimeOffset.MinValue ? null : item.PublishDate,
                        Language: source.PrimaryLanguage,
                        SourceCountryCode: source.CountryCode,
                        ImageUrl: null,
                        RegionHint: source.Region,
                        CategoryHint: null));
                }
            }
            catch (Exception ex)
            {
                logger.LogWarning(ex, "RSS ingestion failed for {Source}", source.CanonicalDomain);
            }
        }

        return results;
    }

    private static string? Truncate(string? value, int max)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var cleaned = value.Trim();
        return cleaned.Length <= max ? cleaned : cleaned[..max];
    }
}
