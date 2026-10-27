using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Ensures Phase 1 endpoint modules still register the expected route patterns.
/// Does not hit Postgres — inspects the host route table only.
/// </summary>
public class RouteInventoryTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public RouteInventoryTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
        });
    }

    [Fact]
    public void Expected_route_groups_are_mapped()
    {
        using var client = _factory.CreateClient();
        var source = _factory.Services.GetRequiredService<EndpointDataSource>();
        var patterns = source.Endpoints
            .OfType<RouteEndpoint>()
            .Select(e => e.RoutePattern.RawText ?? string.Empty)
            .ToList();

        patterns.Should().Contain(p => p == "/health");
        patterns.Should().Contain(p => p == "/ready");
        patterns.Should().Contain(p => p.Contains("app/config", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("world/status", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("regions", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("countries", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("stories", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("search", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("questions", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("reports", StringComparison.Ordinal));
        patterns.Should().Contain(p => p.Contains("admin/ingestion", StringComparison.Ordinal));
    }
}
