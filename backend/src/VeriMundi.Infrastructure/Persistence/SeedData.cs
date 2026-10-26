using Microsoft.EntityFrameworkCore;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;

namespace VeriMundi.Infrastructure.Persistence;

public static class SeedData
{
    public static async Task InitialiseAsync(VeriMundiDbContext db, CancellationToken cancellationToken = default)
    {
        if (db.Database.IsRelational())
        {
            await db.Database.MigrateAsync(cancellationToken);
        }
        else
        {
            await db.Database.EnsureCreatedAsync(cancellationToken);
        }

        if (!await db.Countries.AnyAsync(cancellationToken))
        {
            db.Countries.AddRange(Countries());
            await db.SaveChangesAsync(cancellationToken);
        }

        if (!await db.Sources.AnyAsync(cancellationToken))
        {
            db.Sources.AddRange(Sources());
            await db.SaveChangesAsync(cancellationToken);
        }
        else
        {
            // Idempotent proposals for existing DBs — never auto-enable.
            await EnsureProposedSourcesAsync(db, cancellationToken);
        }
    }

    /// Adds missing proposed registry rows without enabling them or changing approvals.
    private static async Task EnsureProposedSourcesAsync(
        VeriMundiDbContext db,
        CancellationToken cancellationToken)
    {
        var proposed = Sources()
            .Where(s => s.LicenceStatus == LicenceStatus.Proposed)
            .ToList();
        foreach (var candidate in proposed)
        {
            var exists = await db.Sources.AnyAsync(
                s => s.CanonicalDomain == candidate.CanonicalDomain,
                cancellationToken);
            if (!exists)
            {
                candidate.Enabled = false;
                db.Sources.Add(candidate);
            }
        }

        if (db.ChangeTracker.HasChanges())
        {
            await db.SaveChangesAsync(cancellationToken);
        }
    }

    private static IEnumerable<Country> Countries() =>
    [
        new() { Code = "NG", Name = "Nigeria", Region = "Africa", Latitude = 9.08, Longitude = 7.40 },
        new() { Code = "KE", Name = "Kenya", Region = "Africa", Latitude = -1.29, Longitude = 36.82 },
        new() { Code = "IN", Name = "India", Region = "Asia", Latitude = 28.61, Longitude = 77.21 },
        new() { Code = "JP", Name = "Japan", Region = "Asia", Latitude = 35.68, Longitude = 139.69 },
        new() { Code = "DE", Name = "Germany", Region = "Europe", Latitude = 52.52, Longitude = 13.40 },
        new() { Code = "PL", Name = "Poland", Region = "Europe", Latitude = 52.23, Longitude = 21.01 },
        new() { Code = "JO", Name = "Jordan", Region = "Middle East", Latitude = 31.95, Longitude = 35.91 },
        new() { Code = "CA", Name = "Canada", Region = "North America", Latitude = 45.42, Longitude = -75.70 },
        new() { Code = "BR", Name = "Brazil", Region = "Latin America and the Caribbean", Latitude = -15.79, Longitude = -47.88 },
        new() { Code = "BB", Name = "Barbados", Region = "Latin America and the Caribbean", Latitude = 13.19, Longitude = -59.54 },
        new() { Code = "NZ", Name = "New Zealand", Region = "Oceania", Latitude = -41.29, Longitude = 174.78 },
        new() { Code = "AU", Name = "Australia", Region = "Oceania", Latitude = -35.28, Longitude = 149.13 },
        new() { Code = "GH", Name = "Ghana", Region = "Africa", Latitude = 5.56, Longitude = -0.19 },
        new() { Code = "PH", Name = "Philippines", Region = "Asia", Latitude = 14.60, Longitude = 120.98 },
        new() { Code = "SE", Name = "Sweden", Region = "Europe", Latitude = 59.33, Longitude = 18.07 },
        new() { Code = "MX", Name = "Mexico", Region = "Latin America and the Caribbean", Latitude = 19.43, Longitude = -99.13 },
        new() { Code = "US", Name = "United States", Region = "North America", Latitude = 38.90, Longitude = -77.04 },
        new() { Code = "EG", Name = "Egypt", Region = "Middle East", Latitude = 30.04, Longitude = 31.24 },
        new() { Code = "ZA", Name = "South Africa", Region = "Africa", Latitude = -25.75, Longitude = 28.19 },
        new() { Code = "ID", Name = "Indonesia", Region = "Asia", Latitude = -6.21, Longitude = 106.85 }
    ];

    private static IEnumerable<Source> Sources() =>
    [
        new()
        {
            Name = "VeriMundi Fixture Desk Africa",
            CanonicalDomain = "fixture.verimundi.local.africa",
            CountryCode = "NG",
            Region = "Africa",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            AttributionRequirements = "Attribute VeriMundi fixture desk",
            Enabled = true,
            WebsiteUrl = "https://fixture.verimundi.local/africa"
        },
        new()
        {
            Name = "VeriMundi Fixture Desk Asia",
            CanonicalDomain = "fixture.verimundi.local.asia",
            CountryCode = "IN",
            Region = "Asia",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            Enabled = true,
            WebsiteUrl = "https://fixture.verimundi.local/asia"
        },
        new()
        {
            Name = "VeriMundi Fixture Desk Europe",
            CanonicalDomain = "fixture.verimundi.local.europe",
            CountryCode = "DE",
            Region = "Europe",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            Enabled = true
        },
        new()
        {
            Name = "VeriMundi Fixture Desk Middle East",
            CanonicalDomain = "fixture.verimundi.local.middleeast",
            CountryCode = "JO",
            Region = "Middle East",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            Enabled = true
        },
        new()
        {
            Name = "VeriMundi Fixture Desk North America",
            CanonicalDomain = "fixture.verimundi.local.na",
            CountryCode = "CA",
            Region = "North America",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            Enabled = true
        },
        new()
        {
            Name = "VeriMundi Fixture Desk LatAm",
            CanonicalDomain = "fixture.verimundi.local.latam",
            CountryCode = "BR",
            Region = "Latin America and the Caribbean",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            Enabled = true
        },
        new()
        {
            Name = "VeriMundi Fixture Desk Oceania",
            CanonicalDomain = "fixture.verimundi.local.oceania",
            CountryCode = "NZ",
            Region = "Oceania",
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.PermittedExcerpt,
            Enabled = true
        },
        new()
        {
            Name = "VeriMundi Fixture Wire",
            CanonicalDomain = "fixture.verimundi.local.wire",
            CountryCode = null,
            Region = null,
            PrimaryLanguage = "en",
            SourceType = SourceType.Wire,
            LicenceStatus = LicenceStatus.Approved,
            ContentUsageStatus = ContentUsageStatus.HeadlineAndLink,
            Enabled = true
        },
        // Proposed only — never Enabled until Tubo/legal approve in source_registry.md.
        new()
        {
            Name = "Example Commercial Outlet (proposed)",
            CanonicalDomain = "example-news.example",
            CountryCode = "US",
            Region = "North America",
            LicenceStatus = LicenceStatus.Proposed,
            ContentUsageStatus = ContentUsageStatus.MetadataOnly,
            Enabled = false,
            FeedUrl = "https://example-news.example/rss"
        },
        new()
        {
            Name = "UN News (proposed RSS)",
            CanonicalDomain = "news.un.org",
            CountryCode = null,
            Region = null,
            PrimaryLanguage = "en",
            SourceType = SourceType.Wire,
            LicenceStatus = LicenceStatus.Proposed,
            ContentUsageStatus = ContentUsageStatus.HeadlineAndLink,
            AttributionRequirements = "Confirm current UN News reuse / attribution terms before enablement",
            Enabled = false,
            WebsiteUrl = "https://news.un.org",
            FeedUrl = "https://news.un.org/feed/subscribe/en/news/all/rss.xml"
        },
        new()
        {
            Name = "ReliefWeb headlines (proposed)",
            CanonicalDomain = "reliefweb.int",
            CountryCode = null,
            Region = null,
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Proposed,
            ContentUsageStatus = ContentUsageStatus.HeadlineAndLink,
            AttributionRequirements = "Confirm ReliefWeb API/terms for headline+link caching",
            Enabled = false,
            WebsiteUrl = "https://reliefweb.int",
            FeedUrl = "https://reliefweb.int/updates/rss.xml"
        },
        new()
        {
            Name = "WHO newsroom (proposed RSS)",
            CanonicalDomain = "who.int",
            CountryCode = null,
            Region = null,
            PrimaryLanguage = "en",
            SourceType = SourceType.Specialist,
            LicenceStatus = LicenceStatus.Proposed,
            ContentUsageStatus = ContentUsageStatus.HeadlineAndLink,
            AttributionRequirements = "Confirm WHO newsroom terms before enablement",
            Enabled = false,
            WebsiteUrl = "https://www.who.int",
            FeedUrl = "https://www.who.int/rss-feeds/news-english.xml"
        },
        new()
        {
            Name = "GDELT DOC 2.0 discovery (proposed)",
            CanonicalDomain = "api.gdeltproject.org",
            CountryCode = null,
            Region = null,
            PrimaryLanguage = "en",
            SourceType = SourceType.Wire,
            LicenceStatus = LicenceStatus.Proposed,
            ContentUsageStatus = ContentUsageStatus.MetadataOnly,
            AttributionRequirements = "Discovery metadata only; original publisher rights still apply",
            Enabled = false,
            WebsiteUrl = "https://www.gdeltproject.org"
        }
    ];
}
