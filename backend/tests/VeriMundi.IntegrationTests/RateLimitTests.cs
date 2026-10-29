using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using VeriMundi.Api.RateLimiting;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Rate-limit behaviour with per-host DI (MemoryRateLimiter), not static process counters.
/// </summary>
public class RateLimitTests
{
    private static WebApplicationFactory<Program> CreateFactory(
        IDictionary<string, string?> overrides) =>
        new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(overrides);
            });
        });

    [Fact]
    public async Task Write_limit_returns_rate_limited_and_retry_after()
    {
        await using var factory = CreateFactory(new Dictionary<string, string?>
        {
            ["RateLimiting:Provider"] = "Memory",
            ["RateLimiting:WritePerMinute"] = "3",
            ["RateLimiting:AskPerMinute"] = "100",
            ["RateLimiting:ReportPerMinute"] = "100",
            ["RateLimiting:RetryAfterSeconds"] = "60",
        });

        factory.Services.GetRequiredService<IRateLimiter>().Should().BeOfType<MemoryRateLimiter>();

        var client = factory.CreateClient();
        var path = "/v1/stories/11111111-1111-1111-1111-111111111111/reports";
        var body = new { reason = "not-a-real-category", details = "probe" };

        for (var i = 0; i < 3; i++)
        {
            var ok = await client.PostAsJsonAsync(path, body);
            ok.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        var limited = await client.PostAsJsonAsync(path, body);
        limited.StatusCode.Should().Be(HttpStatusCode.TooManyRequests);
        limited.Headers.RetryAfter.Should().NotBeNull();
        limited.Headers.RetryAfter!.Delta.Should().NotBeNull();
        limited.Headers.RetryAfter.Delta!.Value.TotalSeconds.Should().BeGreaterThan(0);

        var json = await limited.Content.ReadAsStringAsync();
        json.Should().Contain("rate_limited");
    }

    [Fact]
    public async Task Ask_limit_returns_ask_rate_limited()
    {
        await using var factory = CreateFactory(new Dictionary<string, string?>
        {
            ["RateLimiting:Provider"] = "Memory",
            ["RateLimiting:WritePerMinute"] = "100",
            ["RateLimiting:AskPerMinute"] = "2",
            ["RateLimiting:ReportPerMinute"] = "100",
        });

        var client = factory.CreateClient();
        var path = "/v1/stories/11111111-1111-1111-1111-111111111111/questions";
        // Empty question fails validation before DB; still consumes Ask + write permits.
        var body = new { question = "" };

        for (var i = 0; i < 2; i++)
        {
            var ok = await client.PostAsJsonAsync(path, body);
            ok.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        var limited = await client.PostAsJsonAsync(path, body);
        limited.StatusCode.Should().Be(HttpStatusCode.TooManyRequests);
        limited.Headers.RetryAfter.Should().NotBeNull();
        var json = await limited.Content.ReadAsStringAsync();
        json.Should().Contain("ask_rate_limited");
    }

    [Fact]
    public async Task Report_limit_returns_report_rate_limited()
    {
        await using var factory = CreateFactory(new Dictionary<string, string?>
        {
            ["RateLimiting:Provider"] = "Memory",
            ["RateLimiting:WritePerMinute"] = "100",
            ["RateLimiting:AskPerMinute"] = "100",
            ["RateLimiting:ReportPerMinute"] = "2",
        });

        var client = factory.CreateClient();
        var path = "/v1/stories/11111111-1111-1111-1111-111111111111/reports";
        var body = new { reason = "not-a-real-category", details = "probe" };

        for (var i = 0; i < 2; i++)
        {
            var ok = await client.PostAsJsonAsync(path, body);
            ok.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        }

        var limited = await client.PostAsJsonAsync(path, body);
        limited.StatusCode.Should().Be(HttpStatusCode.TooManyRequests);
        limited.Headers.RetryAfter.Should().NotBeNull();
        var json = await limited.Content.ReadAsStringAsync();
        json.Should().Contain("report_rate_limited");
    }

    [Fact]
    public async Task Separate_hosts_do_not_share_memory_counters()
    {
        var settings = new Dictionary<string, string?>
        {
            ["RateLimiting:Provider"] = "Memory",
            ["RateLimiting:WritePerMinute"] = "1",
            ["RateLimiting:AskPerMinute"] = "100",
            ["RateLimiting:ReportPerMinute"] = "100",
        };

        await using var factoryA = CreateFactory(settings);
        await using var factoryB = CreateFactory(settings);

        var path = "/v1/stories/11111111-1111-1111-1111-111111111111/reports";
        var body = new { reason = "not-a-real-category", details = "probe" };

        var firstA = await factoryA.CreateClient().PostAsJsonAsync(path, body);
        firstA.StatusCode.Should().Be(HttpStatusCode.BadRequest);

        var limitedA = await factoryA.CreateClient().PostAsJsonAsync(path, body);
        limitedA.StatusCode.Should().Be(HttpStatusCode.TooManyRequests);

        // Fresh host → fresh MemoryRateLimiter singleton (no static ConcurrentDictionary flake).
        var firstB = await factoryB.CreateClient().PostAsJsonAsync(path, body);
        firstB.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}
