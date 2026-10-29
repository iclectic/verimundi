using FluentAssertions;
using VeriMundi.Application.Safety;

namespace VeriMundi.UnitTests;

public class StoryReportReasonsTests
{
    [Theory]
    [InlineData("Incorrect summary")]
    [InlineData("Unsupported claim")]
    [InlineData("Outdated information")]
    [InlineData("Misleading classification")]
    [InlineData("Broken source")]
    [InlineData("Other")]
    public void Allowed_reasons_normalize(string reason)
    {
        StoryReportReasons.TryNormalize(reason, out var normalized).Should().BeTrue();
        normalized.Should().Be(reason);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("spam")]
    [InlineData("incorrect summary")]
    public void Unknown_or_empty_reasons_rejected(string reason)
    {
        StoryReportReasons.TryNormalize(reason, out _).Should().BeFalse();
    }

    [Fact]
    public void Details_respect_max_length()
    {
        StoryReportReasons.IsDetailsValid(null).Should().BeTrue();
        StoryReportReasons.IsDetailsValid(new string('x', StoryReportReasons.MaxDetailsLength))
            .Should().BeTrue();
        StoryReportReasons.IsDetailsValid(new string('x', StoryReportReasons.MaxDetailsLength + 1))
            .Should().BeFalse();
    }
}
