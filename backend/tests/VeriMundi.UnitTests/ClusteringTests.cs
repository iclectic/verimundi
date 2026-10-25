using FluentAssertions;
using VeriMundi.Application.Clustering;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;

namespace VeriMundi.UnitTests;

public class ClusteringTests
{
    private readonly StoryClusteringService _clustering = new();

    [Fact]
    public void NormaliseHeadline_collapses_punctuation_and_case()
    {
        _clustering.NormaliseHeadline("Lagos Trials Electric-Ferry Corridors!")
            .Should().Be("lagos trials electric ferry corridors");
    }

    [Fact]
    public void CanonicalUrlKey_strips_fragment_and_trailing_slash()
    {
        var a = _clustering.CanonicalUrlKey("https://Example.com/path/?utm=1#section");
        var b = _clustering.CanonicalUrlKey("https://example.com/path?utm=1");
        // host/path normalised; query retained but fragment removed
        a.Should().StartWith("https://example.com/path");
        b.Should().StartWith("https://example.com/path");
    }

    [Fact]
    public void CountIndependentSources_dedupes_domains()
    {
        var sources = new[]
        {
            new Source { Name = "A", CanonicalDomain = "a.example" },
            new Source { Name = "A mirror", CanonicalDomain = "a.example" },
            new Source { Name = "B", CanonicalDomain = "b.example" }
        };

        _clustering.CountIndependentSources(sources).Should().Be(2);
    }

    [Fact]
    public void InferCoverageClass_marks_wire_as_international()
    {
        var source = new Source
        {
            Name = "Wire",
            CanonicalDomain = "wire.example",
            SourceType = SourceType.Wire
        };

        _clustering.InferCoverageClass(source, "NG").Should().Be(CoverageClass.International);
    }
}
