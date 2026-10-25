namespace VeriMundi.Application.Abstractions;

public interface IAiSynthesisService
{
    Task<AiSynthesisResult> SynthesiseAsync(
        AiSynthesisRequest request,
        CancellationToken cancellationToken = default);

    Task<AiQuestionResult> AnswerQuestionAsync(
        AiQuestionRequest request,
        CancellationToken cancellationToken = default);
}

public sealed record AiSynthesisRequest(
    Guid StoryId,
    string Headline,
    IReadOnlyList<AiSourceEvidence> Sources);

public sealed record AiSourceEvidence(
    Guid ArticleId,
    string SourceId,
    string Publisher,
    string Headline,
    string? Excerpt,
    string CoverageClass);

public sealed record AiConfirmedFact(string Text, IReadOnlyList<string> SourceIds);

public sealed record AiDisputedClaim(
    string Text,
    IReadOnlyList<string> SupportingSourceIds,
    IReadOnlyList<string> DisputingSourceIds);

public sealed record AiSynthesisResult(
    string Summary,
    string WhyItMatters,
    IReadOnlyList<AiConfirmedFact> ConfirmedFacts,
    IReadOnlyList<AiDisputedClaim> DisputedClaims,
    IReadOnlyList<string> Uncertainties,
    string Severity,
    string SeverityReason,
    string Tone,
    double ConfidenceScore,
    bool InsufficientEvidence);

public sealed record AiQuestionRequest(
    Guid StoryId,
    string Question,
    string Headline,
    string Summary,
    IReadOnlyList<AiSourceEvidence> Sources,
    IReadOnlyList<AiConfirmedFact> ConfirmedFacts,
    IReadOnlyList<string> Uncertainties);

public sealed record AiQuestionResult(
    string Answer,
    IReadOnlyList<string> SourceIds,
    double Confidence,
    string? Uncertainty,
    DateTimeOffset GeneratedAt,
    bool InsufficientEvidence);
