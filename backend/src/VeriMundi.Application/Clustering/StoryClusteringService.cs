using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;

namespace VeriMundi.Application.Clustering;

public sealed class StoryClusteringService
{
    private static readonly Regex NonWord = new("[^a-z0-9\\s]", RegexOptions.Compiled | RegexOptions.CultureInvariant);

    public string NormaliseHeadline(string headline)
    {
        var lower = headline.Trim().ToLowerInvariant();
        lower = NonWord.Replace(lower, " ");
        return string.Join(' ', lower.Split(' ', StringSplitOptions.RemoveEmptyEntries));
    }

    public string CanonicalUrlKey(string url)
    {
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri))
        {
            return url.Trim().ToLowerInvariant();
        }

        var builder = new UriBuilder(uri)
        {
            Scheme = uri.Scheme.ToLowerInvariant(),
            Port = -1,
            Fragment = string.Empty
        };
        var path = builder.Path.TrimEnd('/').ToLowerInvariant();
        return $"{builder.Scheme}://{builder.Host.ToLowerInvariant()}{path}{builder.Query}".ToLowerInvariant();
    }

    public string Hash(string value)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(value));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    public string ClusterKey(Article article, string? regionHint)
    {
        var normalised = NormaliseHeadline(article.Headline);
        var day = (article.PublishedAt ?? article.DiscoveredAt).UtcDateTime.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        var country = article.SourceCountryCode ?? "ZZ";
        var region = regionHint ?? "Unknown";
        return Hash($"{normalised}|{day}|{country}|{region}");
    }

    public CoverageClass InferCoverageClass(Source source, string? storyCountry)
    {
        if (source.SourceType is SourceType.Wire or SourceType.Aggregator)
        {
            return CoverageClass.International;
        }

        if (!string.IsNullOrWhiteSpace(storyCountry) &&
            !string.IsNullOrWhiteSpace(source.CountryCode) &&
            string.Equals(storyCountry, source.CountryCode, StringComparison.OrdinalIgnoreCase))
        {
            return CoverageClass.Local;
        }

        if (!string.IsNullOrWhiteSpace(source.Region))
        {
            return CoverageClass.Regional;
        }

        return CoverageClass.International;
    }

    public int CountIndependentSources(IEnumerable<Source> sources)
    {
        return sources
            .Select(s => s.CanonicalDomain.ToLowerInvariant())
            .Distinct()
            .Count();
    }
}
