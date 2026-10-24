namespace VeriMundi.Application.Ingestion;

public sealed record IngestedArticle(
    string ProviderName,
    string SourceDomain,
    string CanonicalUrl,
    string Headline,
    string? PermittedExcerpt,
    string? Author,
    DateTimeOffset? PublishedAt,
    string Language,
    string? SourceCountryCode,
    string? ImageUrl,
    string? RegionHint,
    string? CategoryHint);
