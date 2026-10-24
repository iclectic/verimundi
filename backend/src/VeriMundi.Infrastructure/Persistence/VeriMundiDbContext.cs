using Microsoft.EntityFrameworkCore;
using VeriMundi.Domain.Entities;

namespace VeriMundi.Infrastructure.Persistence;

public class VeriMundiDbContext(DbContextOptions<VeriMundiDbContext> options) : DbContext(options)
{
    public DbSet<Source> Sources => Set<Source>();
    public DbSet<Article> Articles => Set<Article>();
    public DbSet<StoryCluster> Stories => Set<StoryCluster>();
    public DbSet<StoryArticleLink> StoryArticleLinks => Set<StoryArticleLink>();
    public DbSet<Claim> Claims => Set<Claim>();
    public DbSet<ClaimEvidence> ClaimEvidence => Set<ClaimEvidence>();
    public DbSet<Country> Countries => Set<Country>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Source>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.CanonicalDomain).IsUnique();
            e.Property(x => x.Name).HasMaxLength(200);
            e.Property(x => x.CanonicalDomain).HasMaxLength(255);
        });

        modelBuilder.Entity<Article>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.CanonicalHash).IsUnique();
            e.HasIndex(x => x.ContentHash);
            e.Property(x => x.CanonicalUrl).HasMaxLength(2000);
            e.Property(x => x.Headline).HasMaxLength(500);
            e.HasOne(x => x.Source).WithMany(x => x.Articles).HasForeignKey(x => x.SourceId);
        });

        modelBuilder.Entity<StoryCluster>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.CanonicalHeadline).HasMaxLength(500);
            e.Property(x => x.AffectedCountryCodes).HasColumnType("text[]");
            e.Property(x => x.Uncertainties).HasColumnType("text[]");
            e.HasIndex(x => x.PrimaryCountryCode);
            e.HasIndex(x => x.UnderreportedScore);
            e.HasIndex(x => x.PositiveImpactScore);
        });

        modelBuilder.Entity<StoryArticleLink>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasIndex(x => new { x.StoryId, x.ArticleId }).IsUnique();
            e.HasOne(x => x.Story).WithMany(x => x.ArticleLinks).HasForeignKey(x => x.StoryId);
            e.HasOne(x => x.Article).WithMany(x => x.StoryLinks).HasForeignKey(x => x.ArticleId);
        });

        modelBuilder.Entity<Claim>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasOne(x => x.Story).WithMany(x => x.Claims).HasForeignKey(x => x.StoryId);
        });

        modelBuilder.Entity<ClaimEvidence>(e =>
        {
            e.HasKey(x => x.Id);
            e.HasOne(x => x.Claim).WithMany(x => x.Evidence).HasForeignKey(x => x.ClaimId);
            e.HasOne(x => x.Article).WithMany().HasForeignKey(x => x.ArticleId);
        });

        modelBuilder.Entity<Country>(e =>
        {
            e.HasKey(x => x.Code);
            e.Property(x => x.Code).HasMaxLength(2);
            e.Property(x => x.Name).HasMaxLength(120);
            e.Property(x => x.Region).HasMaxLength(80);
        });
    }
}
