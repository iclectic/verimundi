using FluentAssertions;
using VeriMundi.Infrastructure.Ingestion;

namespace VeriMundi.UnitTests;

public class GdeltArtListParserTests
{
    [Fact]
    public void Parse_maps_publisher_domain_and_skips_excerpts()
    {
        const string json = """
            {
              "articles": [
                {
                  "url": "https://www.example.com/world/story?id=1",
                  "title": "Example headline",
                  "seendate": "20261026T153000Z",
                  "domain": "example.com",
                  "language": "English",
                  "sourcecountry": "United States"
                },
                {
                  "url": "not-a-url",
                  "title": "Broken"
                },
                {
                  "url": "https://news.un.org/en/story/2026/10/example",
                  "title": "UN story",
                  "seendate": "20261026T160000Z",
                  "domain": "news.un.org",
                  "language": "English"
                }
              ]
            }
            """;

        var parsed = GdeltArtListParser.Parse(json, "gdelt", maxItems: 10);

        parsed.Should().HaveCount(2);
        parsed[0].SourceDomain.Should().Be("example.com");
        parsed[0].CanonicalUrl.Should().Be("https://www.example.com/world/story?id=1");
        parsed[0].Headline.Should().Be("Example headline");
        parsed[0].PermittedExcerpt.Should().BeNull();
        parsed[0].PublishedAt.Should().NotBeNull();
        parsed[0].Language.Should().Be("en");

        parsed[1].SourceDomain.Should().Be("news.un.org");
        parsed[1].Headline.Should().Be("UN story");
    }

    [Fact]
    public void Parse_respects_max_items_and_empty_payload()
    {
        const string json = """
            {
              "articles": [
                { "url": "https://a.example/1", "title": "A", "domain": "a.example" },
                { "url": "https://b.example/2", "title": "B", "domain": "b.example" }
              ]
            }
            """;

        GdeltArtListParser.Parse(json, "gdelt", maxItems: 1).Should().HaveCount(1);
        GdeltArtListParser.Parse("{}", "gdelt", maxItems: 5).Should().BeEmpty();
        GdeltArtListParser.Parse("", "gdelt", maxItems: 5).Should().BeEmpty();
    }
}
