using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Host smoke tests that do not require PostgreSQL.
/// Postgres-backed stories/search/Ask/report paths live in <see cref="PostgresDataPlaneTests"/>.
/// </summary>
public class ApiSmokeTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public ApiSmokeTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
        });
    }

    [Fact]
    public async Task Health_endpoint_is_mapped()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/health");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task App_config_endpoint_is_mapped()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/v1/app/config");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var json = await response.Content.ReadAsStringAsync();
        json.Should().Contain("maintenanceMode");
        json.Should().Contain("minimumAppVersion");
        json.Should().Contain("enableRss");
        json.Should().Contain("enableGdelt");
    }

    [Fact]
    public async Task Report_rejects_unknown_reason_before_story_lookup()
    {
        var client = _factory.CreateClient();
        var response = await client.PostAsJsonAsync(
            "/v1/stories/11111111-1111-1111-1111-111111111111/reports",
            new { reason = "not-a-real-category", details = "probe" });
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var json = await response.Content.ReadAsStringAsync();
        json.Should().Contain("invalid_reason");
    }
}
