namespace VeriMundi.Api.Contracts;

public sealed record ApiError(string Code, string Message, string? Detail = null);

public sealed record PagedResponse<T>(IReadOnlyList<T> Items, int Page, int PageSize, int Total);

public sealed record WorldStatusDto(
    DateTimeOffset GeneratedAt,
    int ActiveStoryCount,
    int CountryCount,
    string Environment);

public sealed record RegionDto(string Id, string Name, string DisplayName);

public sealed record CountryDto(
    string Code,
    string Name,
    string Region,
    double Latitude,
    double Longitude,
    string CurrentSeverity,
    int ActiveStoryCount,
    int PositiveStoryCount,
    DateTimeOffset LastUpdated);

public sealed record SourceArticleDto(
    string Id,
    string Name,
    string ArticleUrl,
    string PublisherUrl,
    string CountryCode,
    string LanguageCode,
    string PublicationType,
    bool IsLocalSource,
    DateTimeOffset PublishedAt,
    string? Author,
    string CredibilityStatus,
    string Headline,
    string CoverageLevel);

public sealed record ConfirmedFactDto(string Text, IReadOnlyList<string> SourceIds);

public sealed record DisputedClaimDto(
    string Text,
    IReadOnlyList<string> SupportingSourceIds,
    IReadOnlyList<string> DisputingSourceIds);

public sealed record StoryDto(
    string Id,
    string Headline,
    string ShortSummary,
    string FullSummary,
    string WhyItMatters,
    IReadOnlyList<string> CountryCodes,
    string PrimaryCountryCode,
    string Region,
    string Category,
    double? Latitude,
    double? Longitude,
    DateTimeOffset FirstPublishedAt,
    DateTimeOffset LastUpdatedAt,
    string Severity,
    string SeverityReason,
    string Tone,
    string VerificationStatus,
    double ConfidenceScore,
    int LocalSourceCount,
    int RegionalSourceCount,
    int InternationalSourceCount,
    int IndependentSourceCount,
    double UnderreportedScore,
    string UnderreportedReason,
    double PositiveImpactScore,
    string RankingReason,
    IReadOnlyList<SourceArticleDto> SourceArticles,
    IReadOnlyList<ConfirmedFactDto> ConfirmedFacts,
    IReadOnlyList<DisputedClaimDto> DisputedClaims,
    IReadOnlyList<string> Uncertainties,
    bool IsDemoContent,
    string? CorrectionNotice,
    DateTimeOffset? CorrectedAt);

public sealed record ClaimDto(
    string Id,
    string Text,
    string Status,
    double Confidence,
    DateTimeOffset FirstObservedAt,
    DateTimeOffset LastObservedAt);

public sealed record QuestionRequest(string Question, IReadOnlyList<string>? SourceIds = null);

public sealed record ReportRequest(string Reason, string? Details = null);

public sealed record ReportResponse(string Id, DateTimeOffset ReceivedAt, string Status);

public sealed record QuestionResponse(
    string Answer,
    bool InsufficientEvidence,
    double ConfidenceScore,
    IReadOnlyList<string> SourceIds,
    string? Uncertainty,
    DateTimeOffset GeneratedAt);
