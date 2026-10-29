using System.Text.Json;
using VeriMundi.Application.Abstractions;

namespace VeriMundi.Infrastructure.Ai;

/// <summary>
/// Shared grounding rules for heuristic and GenAI paths: never invent unsupported
/// casualties/quotes/stats; keep source IDs inside the supplied evidence set.
/// </summary>
public static class GroundedAiValidator
{
    public static readonly string InsufficientSummaryMessage =
        "VeriMundi does not currently have enough reliable source material to summarise this story.";

    public static readonly string InsufficientAnswerMessage =
        "VeriMundi does not currently have enough reliable source material to answer that with confidence.";

    public static AiSynthesisResult InsufficientSynthesis(string? uncertainty = null) =>
        new(
            Summary: InsufficientSummaryMessage,
            WhyItMatters: string.Empty,
            ConfirmedFacts: [],
            DisputedClaims: [],
            Uncertainties: [uncertainty ?? "No source articles were available for synthesis."],
            Severity: "general",
            SeverityReason: "Insufficient evidence to assess severity.",
            Tone: "neutral",
            ConfidenceScore: 0,
            InsufficientEvidence: true);

    public static AiQuestionResult InsufficientAnswer(string? message = null) =>
        new(
            Answer: message ?? InsufficientAnswerMessage,
            SourceIds: [],
            Confidence: 0.1,
            Uncertainty: message ?? InsufficientAnswerMessage,
            GeneratedAt: DateTimeOffset.UtcNow,
            InsufficientEvidence: true);

    public static bool IsCertaintyPrompt(string question)
    {
        var q = question.Trim();
        return q.Contains("prove", StringComparison.OrdinalIgnoreCase) ||
               ContainsWholeWord(q, "certain") ||
               ContainsWholeWord(q, "certainty");
    }

    public static AiSynthesisResult SanitiseSynthesis(
        AiSynthesisResult raw,
        IReadOnlyList<AiSourceEvidence> evidence)
    {
        if (evidence.Count == 0 || raw.InsufficientEvidence)
        {
            return InsufficientSynthesis(
                raw.Uncertainties.FirstOrDefault() ??
                "Insufficient evidence returned by synthesis provider.");
        }

        var allowed = evidence.Select(e => e.SourceId).ToHashSet(StringComparer.Ordinal);
        var facts = raw.ConfirmedFacts
            .Select(f => new AiConfirmedFact(
                Text: Truncate(f.Text, 500),
                SourceIds: f.SourceIds.Where(allowed.Contains).Distinct().ToList()))
            .Where(f => f.SourceIds.Count > 0 && !string.IsNullOrWhiteSpace(f.Text))
            .Take(8)
            .ToList();

        var disputed = raw.DisputedClaims
            .Select(d => new AiDisputedClaim(
                Text: Truncate(d.Text, 500),
                SupportingSourceIds: d.SupportingSourceIds.Where(allowed.Contains).Distinct().ToList(),
                DisputingSourceIds: d.DisputingSourceIds.Where(allowed.Contains).Distinct().ToList()))
            .Where(d => !string.IsNullOrWhiteSpace(d.Text) &&
                        (d.SupportingSourceIds.Count > 0 || d.DisputingSourceIds.Count > 0))
            .Take(6)
            .ToList();

        var uncertainties = raw.Uncertainties
            .Where(u => !string.IsNullOrWhiteSpace(u))
            .Select(u => Truncate(u, 400))
            .Distinct()
            .Take(8)
            .ToList();

        if (uncertainties.Count == 0)
        {
            uncertainties.Add("Later developments may not yet appear in the supplied material.");
        }

        var summary = string.IsNullOrWhiteSpace(raw.Summary)
            ? InsufficientSummaryMessage
            : Truncate(raw.Summary.Trim(), 1200);

        var insufficient = raw.InsufficientEvidence ||
                           string.Equals(summary, InsufficientSummaryMessage, StringComparison.Ordinal) ||
                           (facts.Count == 0 && summary.Contains("enough reliable source material", StringComparison.OrdinalIgnoreCase));

        return new AiSynthesisResult(
            Summary: summary,
            WhyItMatters: Truncate(raw.WhyItMatters?.Trim() ?? string.Empty, 800),
            ConfirmedFacts: facts,
            DisputedClaims: disputed,
            Uncertainties: uncertainties,
            Severity: NormaliseSeverity(raw.Severity),
            SeverityReason: Truncate(
                string.IsNullOrWhiteSpace(raw.SeverityReason)
                    ? "Severity assessed only from supplied evidence."
                    : raw.SeverityReason.Trim(),
                400),
            Tone: NormaliseTone(raw.Tone),
            ConfidenceScore: Math.Clamp(raw.ConfidenceScore, 0, 1),
            InsufficientEvidence: insufficient);
    }

    public static AiQuestionResult SanitiseAnswer(
        AiQuestionResult raw,
        IReadOnlyList<AiSourceEvidence> evidence)
    {
        if (evidence.Count == 0 || raw.InsufficientEvidence)
        {
            return InsufficientAnswer(raw.Uncertainty ?? raw.Answer);
        }

        var allowed = evidence.Select(e => e.SourceId).ToHashSet(StringComparer.Ordinal);
        var ids = raw.SourceIds.Where(allowed.Contains).Distinct().Take(6).ToList();
        if (ids.Count == 0)
        {
            return InsufficientAnswer();
        }

        return new AiQuestionResult(
            Answer: Truncate(raw.Answer.Trim(), 2000),
            SourceIds: ids,
            Confidence: Math.Clamp(raw.Confidence, 0, 1),
            Uncertainty: string.IsNullOrWhiteSpace(raw.Uncertainty)
                ? "Answer is grounded only on the listed sources for this story."
                : Truncate(raw.Uncertainty.Trim(), 500),
            GeneratedAt: raw.GeneratedAt == default ? DateTimeOffset.UtcNow : raw.GeneratedAt,
            InsufficientEvidence: false);
    }

    public static AiSynthesisResult? TryParseSynthesisJson(string json, IReadOnlyList<AiSourceEvidence> evidence)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            var insufficient = root.TryGetProperty("insufficientEvidence", out var ie) && ie.GetBoolean();
            if (insufficient)
            {
                return InsufficientSynthesis(ReadStringArray(root, "uncertainties").FirstOrDefault());
            }

            var facts = new List<AiConfirmedFact>();
            if (root.TryGetProperty("confirmedFacts", out var factsEl) && factsEl.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in factsEl.EnumerateArray())
                {
                    var text = GetString(item, "text");
                    if (string.IsNullOrWhiteSpace(text))
                    {
                        continue;
                    }

                    facts.Add(new AiConfirmedFact(text, ReadStringArray(item, "sourceIds")));
                }
            }

            var disputed = new List<AiDisputedClaim>();
            if (root.TryGetProperty("disputedClaims", out var disputedEl) && disputedEl.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in disputedEl.EnumerateArray())
                {
                    var text = GetString(item, "text");
                    if (string.IsNullOrWhiteSpace(text))
                    {
                        continue;
                    }

                    disputed.Add(new AiDisputedClaim(
                        text,
                        ReadStringArray(item, "supportingSourceIds"),
                        ReadStringArray(item, "disputingSourceIds")));
                }
            }

            var raw = new AiSynthesisResult(
                Summary: GetString(root, "summary") ?? string.Empty,
                WhyItMatters: GetString(root, "whyItMatters") ?? string.Empty,
                ConfirmedFacts: facts,
                DisputedClaims: disputed,
                Uncertainties: ReadStringArray(root, "uncertainties"),
                Severity: GetString(root, "severity") ?? "developing",
                SeverityReason: GetString(root, "severityReason") ?? string.Empty,
                Tone: GetString(root, "tone") ?? "neutral",
                ConfidenceScore: root.TryGetProperty("confidenceScore", out var c) && c.TryGetDouble(out var conf)
                    ? conf
                    : 0.4,
                InsufficientEvidence: false);

            return SanitiseSynthesis(raw, evidence);
        }
        catch (JsonException)
        {
            return null;
        }
    }

    public static AiQuestionResult? TryParseAnswerJson(string json, IReadOnlyList<AiSourceEvidence> evidence)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            var insufficient = root.TryGetProperty("insufficientEvidence", out var ie) && ie.GetBoolean();
            if (insufficient)
            {
                return InsufficientAnswer(GetString(root, "answer") ?? GetString(root, "uncertainty"));
            }

            var raw = new AiQuestionResult(
                Answer: GetString(root, "answer") ?? string.Empty,
                SourceIds: ReadStringArray(root, "sourceIds"),
                Confidence: root.TryGetProperty("confidence", out var c) && c.TryGetDouble(out var conf)
                    ? conf
                    : 0.4,
                Uncertainty: GetString(root, "uncertainty"),
                GeneratedAt: DateTimeOffset.UtcNow,
                InsufficientEvidence: false);

            return SanitiseAnswer(raw, evidence);
        }
        catch (JsonException)
        {
            return null;
        }
    }

    public static string ExtractChatContent(string responseJson)
    {
        using var doc = JsonDocument.Parse(responseJson);
        var content = doc.RootElement
            .GetProperty("choices")[0]
            .GetProperty("message")
            .GetProperty("content")
            .GetString();
        return content?.Trim() ?? string.Empty;
    }

    private static string NormaliseSeverity(string? value) =>
        (value ?? string.Empty).Trim().ToLowerInvariant() switch
        {
            "critical" => "critical",
            "serious" => "serious",
            "developing" => "developing",
            "general" => "general",
            _ => "developing"
        };

    private static string NormaliseTone(string? value) =>
        (value ?? string.Empty).Trim().ToLowerInvariant() switch
        {
            "positive" => "positive",
            "concerning" => "concerning",
            "mixed" => "mixed",
            _ => "neutral"
        };

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max];

    private static string? GetString(JsonElement element, string name) =>
        element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString()
            : null;

    private static IReadOnlyList<string> ReadStringArray(JsonElement parent, string name)
    {
        if (!parent.TryGetProperty(name, out var el) || el.ValueKind != JsonValueKind.Array)
        {
            return Array.Empty<string>();
        }

        return el.EnumerateArray()
            .Where(x => x.ValueKind == JsonValueKind.String)
            .Select(x => x.GetString())
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Cast<string>()
            .ToList();
    }

    private static bool ContainsWholeWord(string text, string word)
    {
        var parts = text.Split(
            new[] { ' ', '\t', '\r', '\n', ',', '.', '?', '!', ';', ':' },
            StringSplitOptions.RemoveEmptyEntries);
        return parts.Any(p => p.Equals(word, StringComparison.OrdinalIgnoreCase));
    }
}
