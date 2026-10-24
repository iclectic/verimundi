using FluentAssertions;
using VeriMundi.Application.Scoring;
using VeriMundi.Domain;

namespace VeriMundi.UnitTests;

public class UnderreportedScorerTests
{
    [Fact]
    public void High_local_low_international_scores_higher_than_widely_covered()
    {
        var (high, _) = UnderreportedScorer.Calculate(
            Severity.Serious, localSourceCount: 8, regionalSourceCount: 3, internationalSourceCount: 0, independentSourceCount: 9, confidence: 0.8);

        var (low, _) = UnderreportedScorer.Calculate(
            Severity.Serious, localSourceCount: 2, regionalSourceCount: 1, internationalSourceCount: 8, independentSourceCount: 9, confidence: 0.8);

        high.Should().BeGreaterThan(low);
    }

    [Fact]
    public void Explanation_avoids_media_bias_claims()
    {
        var (_, reason) = UnderreportedScorer.Calculate(
            Severity.Developing, 5, 2, 1, 6, 0.7);

        reason.Should().Contain("local or regional");
        reason.Should().NotContain("ignoring");
        reason.Should().NotContain("Western");
    }
}
