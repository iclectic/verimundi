using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using VeriMundi.Application.Abstractions;

namespace VeriMundi.Infrastructure.Ai;

/// <summary>
/// OpenAI-compatible chat completions for grounded synthesis / Ask.
/// Uses only supplied evidence; falls back to heuristic on transport/parse failure.
/// </summary>
public sealed class OpenAiCompatibleSynthesisService(
    IHttpClientFactory httpClientFactory,
    IOptions<AiOptions> options,
    HeuristicAiSynthesisService heuristic,
    ILogger<OpenAiCompatibleSynthesisService> logger) : IAiSynthesisService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public async Task<AiSynthesisResult> SynthesiseAsync(
        AiSynthesisRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.Sources.Count == 0)
        {
            return GroundedAiValidator.InsufficientSynthesis();
        }

        try
        {
            var content = await CompleteAsync(
                SystemSynthesisPrompt(),
                BuildSynthesisUserPayload(request),
                cancellationToken);
            var parsed = GroundedAiValidator.TryParseSynthesisJson(content, request.Sources);
            if (parsed is not null)
            {
                return parsed;
            }

            logger.LogWarning("GenAI synthesis returned unparseable JSON; falling back to heuristic");
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "GenAI synthesis failed; falling back to heuristic");
        }

        var fallback = await heuristic.SynthesiseAsync(request, cancellationToken);
        var uncertainties = fallback.Uncertainties.ToList();
        uncertainties.Insert(0, "GenAI provider unavailable; heuristic synthesis used.");
        return fallback with { Uncertainties = uncertainties };
    }

    public async Task<AiQuestionResult> AnswerQuestionAsync(
        AiQuestionRequest request,
        CancellationToken cancellationToken = default)
    {
        var q = request.Question.Trim();
        if (q.Length == 0 || q.Length > 500)
        {
            return GroundedAiValidator.InsufficientAnswer("Question must be between 1 and 500 characters.");
        }

        if (request.Sources.Count == 0 || GroundedAiValidator.IsCertaintyPrompt(q))
        {
            return GroundedAiValidator.InsufficientAnswer();
        }

        try
        {
            var content = await CompleteAsync(
                SystemAskPrompt(),
                BuildAskUserPayload(request),
                cancellationToken);
            var parsed = GroundedAiValidator.TryParseAnswerJson(content, request.Sources);
            if (parsed is not null)
            {
                return parsed;
            }

            logger.LogWarning("GenAI Ask returned unparseable JSON; falling back to heuristic");
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "GenAI Ask failed; falling back to heuristic");
        }

        var fallback = await heuristic.AnswerQuestionAsync(request, cancellationToken);
        return fallback with
        {
            Uncertainty = "GenAI provider unavailable; heuristic answer used. " + (fallback.Uncertainty ?? string.Empty)
        };
    }

    private async Task<string> CompleteAsync(
        string systemPrompt,
        object userPayload,
        CancellationToken cancellationToken)
    {
        var opts = options.Value;
        var client = httpClientFactory.CreateClient("ai");
        using var request = new HttpRequestMessage(HttpMethod.Post, "chat/completions");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", opts.ApiKey.Trim());

        var body = new
        {
            model = opts.Model,
            temperature = opts.Temperature,
            max_tokens = opts.MaxOutputTokens,
            response_format = new { type = "json_object" },
            messages = new object[]
            {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = JsonSerializer.Serialize(userPayload, JsonOptions) }
            }
        };

        request.Content = new StringContent(
            JsonSerializer.Serialize(body, JsonOptions),
            Encoding.UTF8,
            "application/json");

        using var response = await client.SendAsync(request, cancellationToken);
        var raw = await response.Content.ReadAsStringAsync(cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException(
                $"AI provider returned {(int)response.StatusCode}: {Truncate(raw, 240)}");
        }

        return GroundedAiValidator.ExtractChatContent(raw);
    }

    private static string SystemSynthesisPrompt() =>
        """
        You are VeriMundi's grounded news synthesiser.
        Use ONLY the supplied evidence articles. Do not use model memory for current events.
        Never invent casualties, quotations, statistics, or named officials that are not in the evidence.
        If evidence is thin or conflicting, set insufficientEvidence=true or list disputes in disputedClaims.
        Every confirmedFacts[].sourceIds value MUST be copied from the supplied sourceId fields.
        Return a single JSON object with keys:
        summary, whyItMatters, confirmedFacts[{text,sourceIds}], disputedClaims[{text,supportingSourceIds,disputingSourceIds}],
        uncertainties[], severity (critical|serious|developing|general), severityReason, tone (positive|neutral|concerning|mixed),
        confidenceScore (0-1), insufficientEvidence (boolean).
        """;

    private static string SystemAskPrompt() =>
        """
        You are VeriMundi's grounded Ask assistant.
        Answer ONLY from the supplied story evidence. If the answer is not supported, set insufficientEvidence=true.
        Never invent casualties, quotations, or statistics. Do not claim certainty.
        sourceIds MUST be taken from the supplied evidence sourceId values.
        Return JSON: answer, sourceIds[], confidence (0-1), uncertainty, insufficientEvidence.
        """;

    private static object BuildSynthesisUserPayload(AiSynthesisRequest request) =>
        new
        {
            storyId = request.StoryId,
            headline = request.Headline,
            evidence = request.Sources.Select(s => new
            {
                sourceId = s.SourceId,
                articleId = s.ArticleId,
                publisher = s.Publisher,
                headline = s.Headline,
                excerpt = s.Excerpt,
                coverageClass = s.CoverageClass
            })
        };

    private static object BuildAskUserPayload(AiQuestionRequest request) =>
        new
        {
            storyId = request.StoryId,
            question = request.Question,
            headline = request.Headline,
            summary = request.Summary,
            confirmedFacts = request.ConfirmedFacts,
            uncertainties = request.Uncertainties,
            evidence = request.Sources.Select(s => new
            {
                sourceId = s.SourceId,
                publisher = s.Publisher,
                headline = s.Headline,
                excerpt = s.Excerpt,
                coverageClass = s.CoverageClass
            })
        };

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max];
}
