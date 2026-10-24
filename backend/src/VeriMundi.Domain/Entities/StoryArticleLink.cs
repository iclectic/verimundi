namespace VeriMundi.Domain.Entities;

public class StoryArticleLink
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid StoryId { get; set; }
    public StoryCluster? Story { get; set; }
    public Guid ArticleId { get; set; }
    public Article? Article { get; set; }
    public string Relationship { get; set; } = "covers";
    public double SimilarityScore { get; set; }
    public CoverageClass SourceCoverageClass { get; set; } = CoverageClass.Regional;
    public DateTimeOffset AddedAt { get; set; } = DateTimeOffset.UtcNow;
}
