using FluentAssertions;
using VeriMundi.Application.Abstractions;
using VeriMundi.Infrastructure.Ai;

namespace VeriMundi.UnitTests;

public class HeuristicAiTests
{
    private readonly HeuristicAiSynthesisService _ai = new();

    [Fact]
    public async Task Synthesise_without_sources_is_insufficient()
    {
        var result = await _ai.SynthesiseAsync(new AiSynthesisRequest(Guid.NewGuid(), "Headline", []));
        result.InsufficientEvidence.Should().BeTrue();
        result.ConfirmedFacts.Should().BeEmpty();
    }

    [Fact]
    public async Task Answer_rejects_certainty_prompts()
    {
        var result = await _ai.AnswerQuestionAsync(new AiQuestionRequest(
            Guid.NewGuid(),
            "Are you certain this happened?",
            "Headline",
            "Summary",
            [new AiSourceEvidence(Guid.NewGuid(), "s1", "Pub", "H", "E", "local")],
            [],
            []));

        result.InsufficientEvidence.Should().BeTrue();
    }
}
