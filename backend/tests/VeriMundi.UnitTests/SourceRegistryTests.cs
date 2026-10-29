using FluentAssertions;
using VeriMundi.Domain;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.UnitTests;

public class SourceRegistryTests
{
    [Fact]
    public void Curated_sources_approve_only_clear_terms_rows()
    {
        var byDomain = SeedData.CuratedSources().ToDictionary(s => s.CanonicalDomain);

        byDomain["news.un.org"].LicenceStatus.Should().Be(LicenceStatus.Approved);
        byDomain["news.un.org"].Enabled.Should().BeTrue();
        byDomain["news.un.org"].ContentUsageStatus.Should().Be(ContentUsageStatus.PermittedExcerpt);
        byDomain["news.un.org"].FeedUrl.Should().NotBeNullOrWhiteSpace();
        byDomain["news.un.org"].AttributionRequirements.Should().Contain("UN News");

        byDomain["api.gdeltproject.org"].LicenceStatus.Should().Be(LicenceStatus.Approved);
        byDomain["api.gdeltproject.org"].Enabled.Should().BeTrue();
        byDomain["api.gdeltproject.org"].ContentUsageStatus.Should().Be(ContentUsageStatus.MetadataOnly);
        byDomain["api.gdeltproject.org"].FeedUrl.Should().BeNull();
        byDomain["api.gdeltproject.org"].AttributionRequirements.Should().Contain("GDELT");

        byDomain["reliefweb.int"].LicenceStatus.Should().Be(LicenceStatus.Restricted);
        byDomain["reliefweb.int"].Enabled.Should().BeFalse();

        byDomain["who.int"].LicenceStatus.Should().Be(LicenceStatus.Restricted);
        byDomain["who.int"].Enabled.Should().BeFalse();

        byDomain["example-news.example"].LicenceStatus.Should().Be(LicenceStatus.Proposed);
        byDomain["example-news.example"].Enabled.Should().BeFalse();
    }

    [Fact]
    public void Live_rss_candidates_exclude_restricted_and_metadata_only()
    {
        var rssEligible = SeedData.CuratedSources()
            .Where(s => s.Enabled &&
                        s.LicenceStatus == LicenceStatus.Approved &&
                        s.FeedUrl != null &&
                        s.ContentUsageStatus is ContentUsageStatus.HeadlineAndLink
                            or ContentUsageStatus.PermittedExcerpt
                            or ContentUsageStatus.FullTextLicensed)
            .Select(s => s.CanonicalDomain)
            .ToList();

        rssEligible.Should().Contain("news.un.org");
        rssEligible.Should().NotContain("reliefweb.int");
        rssEligible.Should().NotContain("who.int");
        rssEligible.Should().NotContain("api.gdeltproject.org");
        rssEligible.Should().NotContain("example-news.example");
    }
}
