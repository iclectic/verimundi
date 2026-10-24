using FluentAssertions;
using VeriMundi.Application.Scoring;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;

namespace VeriMundi.UnitTests;

public class WorldPulseRankerTests
{
    [Fact]
    public void RankWithRegionalBalance_reserves_regions_when_available()
    {
        var stories = WorldPulseRanker.Regions.Select((region, index) => new StoryCluster
        {
            CanonicalHeadline = $"Story {region}",
            PrimaryCountryCode = "XX",
            Region = region,
            Severity = Severity.General,
            IndependentSourceCount = 1,
            ConfidenceScore = 0.5,
            LastUpdatedAt = DateTimeOffset.UtcNow.AddHours(-index)
        }).ToList();

        // Add many high-scoring stories in one region
        for (var i = 0; i < 20; i++)
        {
            stories.Add(new StoryCluster
            {
                CanonicalHeadline = $"Europe flood {i}",
                PrimaryCountryCode = "DE",
                Region = "Europe",
                Severity = Severity.Critical,
                IndependentSourceCount = 10,
                ConfidenceScore = 0.9,
                LastUpdatedAt = DateTimeOffset.UtcNow
            });
        }

        var ranked = WorldPulseRanker.RankWithRegionalBalance(stories, take: 10);
        ranked.Select(s => s.Region).Distinct().Count().Should().BeGreaterThanOrEqualTo(7);
    }
}
