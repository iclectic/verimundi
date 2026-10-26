using System.Net;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Host smoke tests that do not require PostgreSQL.
/// Full Postgres-backed ingestion is exercised via local <c>dotnet run</c> + curl.
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
}
