namespace VeriMundi.Domain.Entities;

public class StoryCluster
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string CanonicalHeadline { get; set; }
    public string ShortSummary { get; set; } = string.Empty;
    public string FullSummary { get; set; } = string.Empty;
    public string WhyItMatters { get; set; } = string.Empty;
    public required string PrimaryCountryCode { get; set; }
    public List<string> AffectedCountryCodes { get; set; } = new();
    public required string Region { get; set; }
    public StoryCategory Category { get; set; } = StoryCategory.Other;
    public Severity Severity { get; set; } = Severity.General;
    public string SeverityReason { get; set; } = string.Empty;
    public double SeverityConfidence { get; set; }
    public DateTimeOffset? SeverityUpdatedAt { get; set; }
    public Tone Tone { get; set; } = Tone.Neutral;
    public VerificationStatus VerificationStatus { get; set; } = VerificationStatus.Developing;
    public double ConfidenceScore { get; set; }
    public int LocalSourceCount { get; set; }
    public int RegionalSourceCount { get; set; }
    public int InternationalSourceCount { get; set; }
    public int IndependentSourceCount { get; set; }
    public double UnderreportedScore { get; set; }
    public string UnderreportedReason { get; set; } = string.Empty;
    public double PositiveImpactScore { get; set; }
    public string RankingReason { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public DateTimeOffset FirstPublishedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset LastUpdatedAt { get; set; } = DateTimeOffset.UtcNow;
    public StoryStatus Status { get; set; } = StoryStatus.Active;
    public DateTimeOffset GeneratedAt { get; set; } = DateTimeOffset.UtcNow;
    public HumanReviewStatus HumanReviewStatus { get; set; } = HumanReviewStatus.None;
    public bool InsufficientEvidence { get; set; }
    public DateTimeOffset? CorrectedAt { get; set; }
    public string? CorrectionNotice { get; set; }

    public ICollection<StoryArticleLink> ArticleLinks { get; set; } = new List<StoryArticleLink>();
    public ICollection<Claim> Claims { get; set; } = new List<Claim>();
    public List<string> Uncertainties { get; set; } = new();
}
