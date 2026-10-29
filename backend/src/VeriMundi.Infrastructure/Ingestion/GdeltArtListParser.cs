using System.Text.Json;
using VeriMundi.Application.Ingestion;

namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// Parses GDELT DOC 2.0 <c>ArtList</c> JSON into discovery candidates.
/// Titles/URLs remain subject to original publisher rights — callers must
/// attribute articles to the publisher domain, not treat GDELT as a republish licence.
/// </summary>
public static class GdeltArtListParser
{
    public static IReadOnlyList<IngestedArticle> Parse(
        string json,
        string providerName,
        int maxItems)
    {
        if (string.IsNullOrWhiteSpace(json) || maxItems <= 0)
        {
            return Array.Empty<IngestedArticle>();
        }

        using var doc = JsonDocument.Parse(json);
        if (!doc.RootElement.TryGetProperty("articles", out var articles) ||
            articles.ValueKind != JsonValueKind.Array)
        {
            return Array.Empty<IngestedArticle>();
        }

        var results = new List<IngestedArticle>();
        foreach (var item in articles.EnumerateArray())
        {
            if (results.Count >= maxItems)
            {
                break;
            }

            var url = GetString(item, "url");
            var title = GetString(item, "title");
            if (string.IsNullOrWhiteSpace(url) || string.IsNullOrWhiteSpace(title))
            {
                continue;
            }

            if (!Uri.TryCreate(url, UriKind.Absolute, out var uri))
            {
                continue;
            }

            var domain = GetString(item, "domain");
            if (string.IsNullOrWhiteSpace(domain))
            {
                domain = uri.Host;
            }

            domain = domain.Trim().ToLowerInvariant();
            if (domain.StartsWith("www.", StringComparison.Ordinal))
            {
                domain = domain[4..];
            }

            results.Add(new IngestedArticle(
                ProviderName: providerName,
                SourceDomain: domain,
                CanonicalUrl: uri.GetLeftPart(UriPartial.Query).TrimEnd('?'),
                Headline: title.Trim(),
                PermittedExcerpt: null,
                Author: null,
                PublishedAt: ParseSeenDate(GetString(item, "seendate")),
                Language: MapLanguage(GetString(item, "language")) ?? "en",
                SourceCountryCode: null,
                ImageUrl: null,
                RegionHint: null,
                CategoryHint: null));
        }

        return results;
    }

    private static string? GetString(JsonElement element, string name) =>
        element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString()
            : null;

    private static DateTimeOffset? ParseSeenDate(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw) || raw.Length < 15)
        {
            return null;
        }

        // GDELT seendate: yyyyMMddTHHmmssZ
        if (DateTimeOffset.TryParseExact(
                raw,
                "yyyyMMdd'T'HHmmss'Z'",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.AssumeUniversal,
                out var parsed))
        {
            return parsed;
        }

        return null;
    }

    private static string? MapLanguage(string? language)
    {
        if (string.IsNullOrWhiteSpace(language))
        {
            return null;
        }

        return language.Trim().ToLowerInvariant() switch
        {
            "english" => "en",
            "spanish" => "es",
            "french" => "fr",
            "arabic" => "ar",
            "chinese" => "zh",
            "russian" => "ru",
            "portuguese" => "pt",
            "german" => "de",
            _ => null
        };
    }
}
