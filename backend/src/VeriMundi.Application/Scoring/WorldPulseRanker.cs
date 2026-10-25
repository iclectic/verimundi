using VeriMundi.Domain;
using VeriMundi.Domain.Entities;

namespace VeriMundi.Application.Scoring;

/// <summary>
/// Explainable World Pulse ranking with regional diversity reservation.
/// </summary>
public static class WorldPulseRanker
{
    public static readonly string[] Regions =
    [
        "Africa",
        "Asia",
        "Europe",
        "Middle East",
        "North America",
        "Latin America and the Caribbean",
        "Oceania"
    ];

    public static double ImportanceScore(StoryCluster story)
    {
        var severity = story.Severity switch
        {
            Severity.Critical => 1.0,
            Severity.Serious => 0.8,
            Severity.Developing => 0.55,
            _ => 0.3
        };

        var recencyHours = Math.Max(1, (DateTimeOffset.UtcNow - story.LastUpdatedAt).TotalHours);
        var recency = Math.Clamp(1.0 / Math.Log10(recencyHours + 10), 0.2, 1.0);
        var independence = Math.Clamp(story.IndependentSourceCount / 8.0, 0.15, 1.0);
        var confidence = Math.Clamp(story.ConfidenceScore, 0.2, 1.0);

        return Math.Round((severity * 0.45 + recency * 0.25 + independence * 0.2 + confidence * 0.1) * 100, 2);
    }

    public static string RankingReason(StoryCluster story, double importance)
    {
        return
            $"Ranked using severity ({story.Severity}), recency, {story.IndependentSourceCount} independent sources, " +
            $"and verification confidence {story.ConfidenceScore:0.00}. Composite importance {importance:0.0}. " +
            "Regional diversity is applied so feeds are not dominated solely by high-volume regions.";
    }

    /// <summary>
    /// Reserve at least one active story per region when available, then fill by importance.
    /// </summary>
    public static IReadOnlyList<StoryCluster> RankWithRegionalBalance(
        IEnumerable<StoryCluster> stories,
        int take = 50)
    {
        var active = stories
            .Where(s => s.Status == StoryStatus.Active)
            .Select(s => (Story: s, Score: ImportanceScore(s)))
            .OrderByDescending(x => x.Score)
            .ToList();

        var selected = new List<StoryCluster>();
        var used = new HashSet<Guid>();

        foreach (var region in Regions)
        {
            var pick = active.FirstOrDefault(x =>
                !used.Contains(x.Story.Id) &&
                string.Equals(x.Story.Region, region, StringComparison.OrdinalIgnoreCase));
            if (pick.Story is not null)
            {
                pick.Story.RankingReason = RankingReason(pick.Story, pick.Score);
                selected.Add(pick.Story);
                used.Add(pick.Story.Id);
            }
        }

        foreach (var item in active)
        {
            if (selected.Count >= take)
            {
                break;
            }

            if (used.Add(item.Story.Id))
            {
                item.Story.RankingReason = RankingReason(item.Story, item.Score);
                selected.Add(item.Story);
            }
        }

        return selected;
    }
}
