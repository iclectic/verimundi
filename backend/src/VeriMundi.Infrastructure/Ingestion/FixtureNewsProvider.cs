using System.Text.Json;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Ingestion;

namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// Deterministic development provider. Loads curated fixture articles shipped with the backend.
/// Not used as a silent production fallback for public reads.
/// </summary>
public sealed class FixtureNewsProvider : INewsProvider
{
    private readonly string _fixturePath;

    public FixtureNewsProvider(string? fixturePath = null)
    {
        _fixturePath = fixturePath ?? Path.Combine(AppContext.BaseDirectory, "Fixtures", "seed_articles.json");
    }

    public string Name => "fixture";

    public async Task<IReadOnlyList<IngestedArticle>> FetchLatestAsync(
        IngestionRequest request,
        CancellationToken cancellationToken = default)
    {
        if (!File.Exists(_fixturePath))
        {
            return Array.Empty<IngestedArticle>();
        }

        await using var stream = File.OpenRead(_fixturePath);
        var items = await JsonSerializer.DeserializeAsync<List<FixtureItem>>(
            stream,
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true },
            cancellationToken) ?? [];

        return items
            .Take(request.MaxItems)
            .Select(i => new IngestedArticle(
                ProviderName: Name,
                SourceDomain: i.SourceDomain,
                CanonicalUrl: i.CanonicalUrl,
                Headline: i.Headline,
                PermittedExcerpt: i.PermittedExcerpt,
                Author: i.Author,
                PublishedAt: i.PublishedAt,
                Language: i.Language ?? "en",
                SourceCountryCode: i.SourceCountryCode,
                ImageUrl: null,
                RegionHint: i.Region,
                CategoryHint: i.Category))
            .ToList();
    }

    private sealed class FixtureItem
    {
        public string SourceDomain { get; set; } = string.Empty;
        public string CanonicalUrl { get; set; } = string.Empty;
        public string Headline { get; set; } = string.Empty;
        public string? PermittedExcerpt { get; set; }
        public string? Author { get; set; }
        public DateTimeOffset? PublishedAt { get; set; }
        public string? Language { get; set; }
        public string? SourceCountryCode { get; set; }
        public string? Region { get; set; }
        public string? Category { get; set; }
    }
}
