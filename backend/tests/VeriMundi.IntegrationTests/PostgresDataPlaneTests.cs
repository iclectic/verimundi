using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using VeriMundi.IntegrationTests.Postgres;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Postgres-backed happy/error paths for stories, search, Ask, and reports.
/// Seed + fixture ingest happen in <see cref="PostgresApiFixture"/> — no developer-only DB state.
/// </summary>
[Collection(PostgresDataPlaneCollection.Name)]
public sealed class PostgresDataPlaneTests
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private readonly PostgresApiFixture _fixture;

    public PostgresDataPlaneTests(PostgresApiFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task Stories_paging_returns_seeded_page()
    {
        var response = await _fixture.Client.GetAsync("/v1/stories?page=1&pageSize=2");
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var page = await response.Content.ReadFromJsonAsync<PagedStories>(JsonOptions);
        page.Should().NotBeNull();
        page!.Page.Should().Be(1);
        page.PageSize.Should().Be(2);
        page.Total.Should().BeGreaterThan(2);
        page.Items.Should().HaveCount(2);
        page.Items.Should().OnlyContain(s => !string.IsNullOrWhiteSpace(s.Id));
        page.Items.Should().OnlyContain(s => !string.IsNullOrWhiteSpace(s.Headline));

        var page2 = await _fixture.Client.GetAsync("/v1/stories?page=2&pageSize=2");
        page2.StatusCode.Should().Be(HttpStatusCode.OK);
        var second = await page2.Content.ReadFromJsonAsync<PagedStories>(JsonOptions);
        second.Should().NotBeNull();
        second!.Items.Should().HaveCount(2);
        second.Items.Select(i => i.Id).Should().NotIntersectWith(page.Items.Select(i => i.Id));
    }

    [Fact]
    public async Task Search_finds_fixture_headline()
    {
        var response = await _fixture.Client.GetAsync("/v1/search?q=Lagos&page=1&pageSize=10");
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var page = await response.Content.ReadFromJsonAsync<PagedStories>(JsonOptions);
        page.Should().NotBeNull();
        page!.Total.Should().BeGreaterThan(0);
        page.Items.Should().NotBeEmpty();
        page.Items.Should().Contain(s =>
            s.Headline.Contains("Lagos", StringComparison.OrdinalIgnoreCase) ||
            s.Headline.Contains("ferry", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task Story_by_id_returns_dto_and_unknown_is_404()
    {
        var list = await _fixture.Client.GetFromJsonAsync<PagedStories>(
            "/v1/stories?page=1&pageSize=1",
            JsonOptions);
        list.Should().NotBeNull();
        var storyId = list!.Items.Should().ContainSingle().Subject.Id;

        var ok = await _fixture.Client.GetAsync($"/v1/stories/{storyId}");
        ok.StatusCode.Should().Be(HttpStatusCode.OK);
        var story = await ok.Content.ReadFromJsonAsync<StoryItem>(JsonOptions);
        story.Should().NotBeNull();
        story!.Id.Should().Be(storyId);
        story.Headline.Should().NotBeNullOrWhiteSpace();
        story.ShortSummary.Should().NotBeNullOrWhiteSpace();

        var missing = await _fixture.Client.GetAsync(
            "/v1/stories/11111111-1111-1111-1111-111111111111");
        missing.StatusCode.Should().Be(HttpStatusCode.NotFound);
        var body = await missing.Content.ReadAsStringAsync();
        body.Should().Contain("story_not_found");
    }

    [Fact]
    public async Task Ask_heuristic_answers_seeded_story()
    {
        var list = await _fixture.Client.GetFromJsonAsync<PagedStories>(
            "/v1/stories?page=1&pageSize=1",
            JsonOptions);
        var storyId = list!.Items.Single().Id;

        var response = await _fixture.Client.PostAsJsonAsync(
            $"/v1/stories/{storyId}/questions",
            new { question = "What is this story about?" });

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var json = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;
        root.GetProperty("answer").GetString().Should().NotBeNullOrWhiteSpace();
        root.TryGetProperty("insufficientEvidence", out _).Should().BeTrue();
        root.TryGetProperty("confidenceScore", out _).Should().BeTrue();
        root.TryGetProperty("sourceIds", out _).Should().BeTrue();
        root.TryGetProperty("generatedAt", out _).Should().BeTrue();
    }

    [Fact]
    public async Task Report_allowlist_accepts_and_missing_story_is_404()
    {
        var list = await _fixture.Client.GetFromJsonAsync<PagedStories>(
            "/v1/stories?page=1&pageSize=1",
            JsonOptions);
        var storyId = list!.Items.Single().Id;

        var accepted = await _fixture.Client.PostAsJsonAsync(
            $"/v1/stories/{storyId}/reports",
            new { reason = "Incorrect summary", details = "Integration probe" });
        accepted.StatusCode.Should().Be(HttpStatusCode.Accepted);
        var acceptedJson = await accepted.Content.ReadAsStringAsync();
        acceptedJson.Should().Contain("received");

        var missing = await _fixture.Client.PostAsJsonAsync(
            "/v1/stories/11111111-1111-1111-1111-111111111111/reports",
            new { reason = "Broken source", details = "missing story" });
        missing.StatusCode.Should().Be(HttpStatusCode.NotFound);
        var missingJson = await missing.Content.ReadAsStringAsync();
        missingJson.Should().Contain("story_not_found");

        var invalid = await _fixture.Client.PostAsJsonAsync(
            $"/v1/stories/{storyId}/reports",
            new { reason = "not-a-real-category", details = "probe" });
        invalid.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var invalidJson = await invalid.Content.ReadAsStringAsync();
        invalidJson.Should().Contain("invalid_reason");
    }

    [Fact]
    public async Task Ready_reports_database_reachable()
    {
        var response = await _fixture.Client.GetAsync("/ready");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var json = await response.Content.ReadAsStringAsync();
        json.Should().Contain("ready");
    }

    private sealed record PagedStories(
        IReadOnlyList<StoryItem> Items,
        int Page,
        int PageSize,
        int Total);

    private sealed record StoryItem(
        string Id,
        string Headline,
        string? ShortSummary = null);
}
