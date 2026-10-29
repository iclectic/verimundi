using System.Text.Json;
using FluentAssertions;
using VeriMundi.Application.Abstractions;
using VeriMundi.Infrastructure.Ai;

namespace VeriMundi.UnitTests;

public class AiEvalFixtureTests
{
    private readonly HeuristicAiSynthesisService _ai = new();

    [Fact]
    public async Task Heuristic_matches_ai_eval_fixtures()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "Fixtures", "ai_eval_cases.json");
        File.Exists(path).Should().BeTrue("ai_eval_cases.json should copy to test output");
        await using var stream = File.OpenRead(path);
        var cases = await JsonSerializer.DeserializeAsync<List<EvalCase>>(stream, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });
        cases.Should().NotBeNull().And.NotBeEmpty();

        foreach (var eval in cases!)
        {
            var evidence = (eval.Sources ?? [])
                .Select(s => new AiSourceEvidence(
                    Guid.NewGuid(),
                    s.SourceId,
                    s.Publisher,
                    s.Headline,
                    s.Excerpt,
                    s.CoverageClass))
                .ToList();

            if (eval.Kind == "synthesis")
            {
                var result = await _ai.SynthesiseAsync(
                    new AiSynthesisRequest(Guid.NewGuid(), eval.Headline ?? "Headline", evidence));
                result.InsufficientEvidence.Should().Be(
                    eval.ExpectInsufficientEvidence,
                    because: eval.Id);
                if (eval.RequireFactSourceIdsFromEvidence)
                {
                    var allowed = evidence.Select(e => e.SourceId).ToHashSet();
                    foreach (var fact in result.ConfirmedFacts)
                    {
                        fact.SourceIds.Should().OnlyContain(id => allowed.Contains(id), because: eval.Id);
                    }
                }
            }
            else if (eval.Kind == "ask")
            {
                var result = await _ai.AnswerQuestionAsync(new AiQuestionRequest(
                    Guid.NewGuid(),
                    eval.Question ?? string.Empty,
                    eval.Headline ?? "Headline",
                    eval.Summary ?? string.Empty,
                    evidence,
                    [],
                    []));
                result.InsufficientEvidence.Should().Be(
                    eval.ExpectInsufficientEvidence,
                    because: eval.Id);
                if (eval.RequireAnswerSourceIdsFromEvidence)
                {
                    var allowed = evidence.Select(e => e.SourceId).ToHashSet();
                    result.SourceIds.Should().OnlyContain(id => allowed.Contains(id), because: eval.Id);
                    result.SourceIds.Should().NotBeEmpty(because: eval.Id);
                }
            }
            else
            {
                throw new InvalidOperationException($"Unknown eval kind {eval.Kind}");
            }
        }
    }

    private sealed class EvalCase
    {
        public string Id { get; set; } = string.Empty;
        public string Kind { get; set; } = string.Empty;
        public string? Headline { get; set; }
        public string? Question { get; set; }
        public string? Summary { get; set; }
        public List<EvalSource>? Sources { get; set; }
        public bool ExpectInsufficientEvidence { get; set; }
        public bool RequireFactSourceIdsFromEvidence { get; set; }
        public bool RequireAnswerSourceIdsFromEvidence { get; set; }
    }

    private sealed class EvalSource
    {
        public string SourceId { get; set; } = string.Empty;
        public string Publisher { get; set; } = string.Empty;
        public string Headline { get; set; } = string.Empty;
        public string? Excerpt { get; set; }
        public string CoverageClass { get; set; } = "local";
    }
}
