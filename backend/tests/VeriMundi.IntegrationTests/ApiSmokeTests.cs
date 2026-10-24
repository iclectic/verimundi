using System.Net;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Light host smoke tests. Full Postgres-backed ingestion is exercised via local `dotnet run` + curl.
/// </summary>
public class ApiSmokeTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public ApiSmokeTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Health_endpoint_is_mapped()
    {
        // Requires local Postgres matching ConnectionStrings:VeriMundi.
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/health");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
