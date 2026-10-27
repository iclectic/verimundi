using VeriMundi.Application.Abstractions;

namespace VeriMundi.Infrastructure.Ai;

/// <summary>
/// Deterministic grounded synthesis for environments without a GenAI API key.
/// Uses only supplied evidence; never invents casualties, quotations, or statistics.
/// </summary>
public sealed class HeuristicAiSynthesisService : IAiSynthesisService
{
    public Task<AiSynthesisResult> SynthesiseAsync(
        AiSynthesisRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.Sources.Count == 0)
        {
            return Task.FromResult(GroundedAiValidator.InsufficientSynthesis());
        }

        var sourceIds = request.Sources.Select(s => s.SourceId).Distinct().ToList();
        var lead = request.Sources[0];
        var summary = string.IsNullOrWhiteSpace(lead.Excerpt)
            ? $"Reporting centres on: {request.Headline}"
            : lead.Excerpt!.Trim();

        var facts = new List<AiConfirmedFact>
        {
            new(
                Text: $"Multiple listed sources discuss: {request.Headline}",
                SourceIds: sourceIds.Take(3).ToList())
        };

        var uncertainties = new List<string>
        {
            "Scale, causation, and later developments may not yet be fully established in the supplied material."
        };

        if (request.Sources.Count == 1)
        {
            uncertainties.Add("Only one source article is currently linked; independent confirmation is limited.");
        }

        var confidence = Math.Clamp(0.35 + (request.Sources.Count * 0.08), 0.35, 0.82);

        var raw = new AiSynthesisResult(
            Summary: summary,
            WhyItMatters:
                "This development may matter for regional awareness because it appears in local or specialist coverage that international feeds can under-index.",
            ConfirmedFacts: facts,
            DisputedClaims: [],
            Uncertainties: uncertainties,
            Severity: "developing",
            SeverityReason: "Heuristic severity pending richer evidence signals; treated as developing.",
            Tone: InferTone(summary),
            ConfidenceScore: Math.Round(confidence, 2),
            InsufficientEvidence: false);
        return Task.FromResult(GroundedAiValidator.SanitiseSynthesis(raw, request.Sources));
    }

    public Task<AiQuestionResult> AnswerQuestionAsync(
        AiQuestionRequest request,
        CancellationToken cancellationToken = default)
    {
        var q = request.Question.Trim();
        if (q.Length == 0 || q.Length > 500)
        {
            return Task.FromResult(
                GroundedAiValidator.InsufficientAnswer("Question must be between 1 and 500 characters."));
        }

        if (request.Sources.Count == 0 || GroundedAiValidator.IsCertaintyPrompt(q))
        {
            return Task.FromResult(GroundedAiValidator.InsufficientAnswer());
        }

        var ids = request.Sources.Take(2).Select(s => s.SourceId).ToList();
        string answer;
        if (q.Contains("uncertain", StringComparison.OrdinalIgnoreCase))
        {
            answer = request.Uncertainties.Count == 0
                ? "The listed sources do not explicitly enumerate remaining uncertainties."
                : string.Join(' ', request.Uncertainties);
        }
        else if (q.Contains("matter", StringComparison.OrdinalIgnoreCase))
        {
            answer = string.IsNullOrWhiteSpace(request.Summary)
                ? "Why this matters is not yet synthesised from the listed sources."
                : $"Based only on the listed sources: {request.Summary}";
        }
        else
        {
            answer =
                $"Based only on the listed sources for “{request.Headline}”: {request.Summary} " +
                "Consult the original publishers for full reporting.";
        }

        var raw = new AiQuestionResult(
            Answer: answer,
            SourceIds: ids,
            Confidence: 0.62,
            Uncertainty: "Answers are retrieval-grounded heuristics unless a GenAI provider is configured.",
            GeneratedAt: DateTimeOffset.UtcNow,
            InsufficientEvidence: false);
        return Task.FromResult(GroundedAiValidator.SanitiseAnswer(raw, request.Sources));
    }

    private static string InferTone(string text)
    {
        var t = text.ToLowerInvariant();
        if (t.Contains("restor") || t.Contains("improv") || t.Contains("launch") || t.Contains("success"))
        {
            return "positive";
        }

        if (t.Contains("risk") || t.Contains("warning") || t.Contains("crisis") || t.Contains("fail"))
        {
            return "concerning";
        }

        return "neutral";
    }
}
