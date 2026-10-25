namespace VeriMundi.Domain.Entities;

public class Source
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }
    public required string CanonicalDomain { get; set; }
    public string? CountryCode { get; set; }
    public string PrimaryLanguage { get; set; } = "en";
    public SourceType SourceType { get; set; } = SourceType.Newsroom;
    public string? WebsiteUrl { get; set; }
    public string? FeedUrl { get; set; }
    public string? Region { get; set; }
    public string? OwnershipMetadata { get; set; }
    public LicenceStatus LicenceStatus { get; set; } = LicenceStatus.Proposed;
    public string? AttributionRequirements { get; set; }
    public ContentUsageStatus ContentUsageStatus { get; set; } = ContentUsageStatus.HeadlineAndLink;
    public bool Enabled { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;

    public ICollection<Article> Articles { get; set; } = new List<Article>();
}
