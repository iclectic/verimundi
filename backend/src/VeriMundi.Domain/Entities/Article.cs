namespace VeriMundi.Domain.Entities;

public class Article
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid SourceId { get; set; }
    public Source? Source { get; set; }
    public required string CanonicalUrl { get; set; }
    public required string Headline { get; set; }
    public string? PermittedExcerpt { get; set; }
    public string? Author { get; set; }
    public DateTimeOffset? PublishedAt { get; set; }
    public DateTimeOffset? UpdatedAt { get; set; }
    public string Language { get; set; } = "en";
    public string? SourceCountryCode { get; set; }
    public DateTimeOffset DiscoveredAt { get; set; } = DateTimeOffset.UtcNow;
    public string? ImageUrl { get; set; }
    public string IngestionProvider { get; set; } = "unknown";
    public string ContentHash { get; set; } = string.Empty;
    public string CanonicalHash { get; set; } = string.Empty;
    public ProcessingStatus ProcessingStatus { get; set; } = ProcessingStatus.Discovered;

    public ICollection<StoryArticleLink> StoryLinks { get; set; } = new List<StoryArticleLink>();
}
