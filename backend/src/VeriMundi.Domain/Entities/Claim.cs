namespace VeriMundi.Domain.Entities;

public class Claim
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid StoryId { get; set; }
    public StoryCluster? Story { get; set; }
    public required string Text { get; set; }
    public ClaimStatus Status { get; set; } = ClaimStatus.Unverified;
    public double Confidence { get; set; }
    public DateTimeOffset FirstObservedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset LastObservedAt { get; set; } = DateTimeOffset.UtcNow;

    public ICollection<ClaimEvidence> Evidence { get; set; } = new List<ClaimEvidence>();
}

public class ClaimEvidence
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ClaimId { get; set; }
    public Claim? Claim { get; set; }
    public Guid ArticleId { get; set; }
    public Article? Article { get; set; }
    public string Relationship { get; set; } = "mentions";
    public bool Supports { get; set; }
    public bool Disputes { get; set; }
    public bool ContextOnly { get; set; }
}
