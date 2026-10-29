using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Ingestion;
using VeriMundi.Domain;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// GDELT DOC 2.0 discovery (ArtList). Metadata / URL discovery only.
/// Does not grant rights to republish underlying publisher headlines or bodies —
/// <see cref="IngestionPipeline"/> still requires each publisher domain to be approved.
/// </summary>
public sealed class GdeltDiscoveryProvider(
    VeriMundiDbContext db,
    IHttpClientFactory httpClientFactory,
    IConfiguration configuration,
    ILogger<GdeltDiscoveryProvider> logger) : INewsProvider
{
    public const string RegistryDomain = "api.gdeltproject.org";
    public const string DefaultQuery = "sourcelang:english";

    public string Name => "gdelt";

    public async Task<IReadOnlyList<IngestedArticle>> FetchLatestAsync(
        IngestionRequest request,
        CancellationToken cancellationToken = default)
    {
        var registry = await db.Sources.AsNoTracking()
            .FirstOrDefaultAsync(s => s.CanonicalDomain == RegistryDomain, cancellationToken);

        if (registry is null ||
            !registry.Enabled ||
            registry.LicenceStatus != LicenceStatus.Approved ||
            registry.ContentUsageStatus != ContentUsageStatus.MetadataOnly)
        {
            logger.LogWarning(
                "GDELT provider skipped: registry row {Domain} must be approved, enabled, and MetadataOnly",
                RegistryDomain);
            return Array.Empty<IngestedArticle>();
        }

        var query = configuration["Ingestion:GdeltQuery"];
        if (string.IsNullOrWhiteSpace(query))
        {
            query = DefaultQuery;
        }

        var max = Math.Clamp(request.MaxItems, 1, 75);
        var url =
            "https://api.gdeltproject.org/api/v2/doc/doc" +
            $"?query={Uri.EscapeDataString(query)}" +
            "&mode=ArtList" +
            "&format=json" +
            $"&maxrecords={max}" +
            "&sort=DateDesc";

        try
        {
            var client = httpClientFactory.CreateClient("ingestion");
            using var response = await client.GetAsync(url, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                logger.LogWarning(
                    "GDELT DOC ArtList returned {StatusCode}",
                    (int)response.StatusCode);
                return Array.Empty<IngestedArticle>();
            }

            var json = await response.Content.ReadAsStringAsync(cancellationToken);
            var parsed = GdeltArtListParser.Parse(json, Name, max);
            logger.LogInformation(
                "GDELT discovery returned {Count} URL candidates (publisher rights still apply)",
                parsed.Count);
            return parsed;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "GDELT DOC ArtList request failed");
            return Array.Empty<IngestedArticle>();
        }
    }
}
