using FluentAssertions;
using VeriMundi.Application.Abstractions;
using VeriMundi.Infrastructure.Ai;

namespace VeriMundi.UnitTests;

public class GroundedAiValidatorTests
{
    private static readonly AiSourceEvidence[] Evidence =
    [
        new(Guid.NewGuid(), "src-a", "Pub A", "H1", "Excerpt A", "local"),
        new(Guid.NewGuid(), "src-b", "Pub B", "H2", "Excerpt B", "regional")
    ];

    [Fact]
    public void SanitiseSynthesis_strips_unknown_source_ids_and_keeps_disputes()
    {
        var raw = new AiSynthesisResult(
            Summary: "Grounded summary from evidence.",
            WhyItMatters: "Regional access.",
            ConfirmedFacts:
            [
                new AiConfirmedFact("Clinic hours expand", ["src-a", "invented"]),
                new AiConfirmedFact("Invented casualty toll of 40", ["not-real"])
            ],
            DisputedClaims:
            [
                new AiDisputedClaim("Hours start in June", ["src-a"], ["src-b"])
            ],
            Uncertainties: ["Timing may shift."],
            Severity: "serious",
            SeverityReason: "Service access.",
            Tone: "positive",
            ConfidenceScore: 1.4,
            InsufficientEvidence: false);

        var cleaned = GroundedAiValidator.SanitiseSynthesis(raw, Evidence);
        cleaned.ConfirmedFacts.Should().ContainSingle();
        cleaned.ConfirmedFacts[0].SourceIds.Should().Equal("src-a");
        cleaned.DisputedClaims.Should().ContainSingle();
        cleaned.ConfidenceScore.Should().Be(1.0);
        cleaned.InsufficientEvidence.Should().BeFalse();
    }

    [Fact]
    public void TryParseSynthesisJson_honours_insufficient_flag()
    {
        const string json = """
            {"summary":"","whyItMatters":"","confirmedFacts":[],"disputedClaims":[],"uncertainties":["thin"],"severity":"general","severityReason":"","tone":"neutral","confidenceScore":0,"insufficientEvidence":true}
            """;
        var parsed = GroundedAiValidator.TryParseSynthesisJson(json, Evidence);
        parsed.Should().NotBeNull();
        parsed!.InsufficientEvidence.Should().BeTrue();
    }

    [Fact]
    public void TryParseAnswerJson_and_extract_chat_content()
    {
        const string chat = """
            {"choices":[{"message":{"content":"{\"answer\":\"Based on sources.\",\"sourceIds\":[\"src-a\"],\"confidence\":0.7,\"uncertainty\":\"check publishers\",\"insufficientEvidence\":false}"}}]}
            """;
        var content = GroundedAiValidator.ExtractChatContent(chat);
        var parsed = GroundedAiValidator.TryParseAnswerJson(content, Evidence);
        parsed.Should().NotBeNull();
        parsed!.InsufficientEvidence.Should().BeFalse();
        parsed.SourceIds.Should().Equal("src-a");
    }

    [Fact]
    public void TryParseAnswerJson_drops_answers_without_valid_source_ids()
    {
        const string json = """
            {"answer":"Invented","sourceIds":["nope"],"confidence":0.9,"uncertainty":null,"insufficientEvidence":false}
            """;
        var parsed = GroundedAiValidator.TryParseAnswerJson(json, Evidence);
        parsed.Should().NotBeNull();
        parsed!.InsufficientEvidence.Should().BeTrue();
    }
}
