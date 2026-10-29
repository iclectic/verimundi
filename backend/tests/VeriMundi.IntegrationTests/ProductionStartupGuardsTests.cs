using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using VeriMundi.Api.Security;

namespace VeriMundi.IntegrationTests;

public class ProductionStartupGuardsTests
{
    [Theory]
    [InlineData("Development")]
    [InlineData("Testing")]
    public void Validate_is_noop_in_local_environments(string envName)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Ops:AdminIngestionToken"] = "",
            ["Cors:AllowedOrigins:0"] = ""
        }).Build();

        var act = () => ProductionStartupGuards.Validate(config, new FakeHostEnvironment(envName));
        act.Should().NotThrow();
    }

    [Fact]
    public void Validate_refuses_empty_ops_token_in_production()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Ops:AdminIngestionToken"] = "  ",
            ["Cors:AllowedOrigins:0"] = "https://app.example.com"
        }).Build();

        var act = () => ProductionStartupGuards.Validate(config, new FakeHostEnvironment("Production"));
        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*Ops:AdminIngestionToken*");
    }

    [Fact]
    public void Validate_refuses_empty_cors_allowlist_in_staging()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Ops:AdminIngestionToken"] = "staging-ops-token",
        }).Build();

        var act = () => ProductionStartupGuards.Validate(config, new FakeHostEnvironment("Staging"));
        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*Cors:AllowedOrigins*");
    }

    [Fact]
    public void Validate_refuses_wildcard_cors_in_production()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Ops:AdminIngestionToken"] = "prod-ops-token",
            ["Cors:AllowedOrigins:0"] = "*",
        }).Build();

        var act = () => ProductionStartupGuards.Validate(config, new FakeHostEnvironment("Production"));
        act.Should().Throw<InvalidOperationException>()
            .WithMessage("*wildcard*");
    }

    [Theory]
    [InlineData("*")]
    [InlineData("https://*.example.com")]
    [InlineData("not-a-url")]
    public void EnsureCorsAllowlist_rejects_wildcards_and_invalid_origins(string origin)
    {
        var act = () => ProductionStartupGuards.EnsureCorsAllowlist([origin]);
        act.Should().Throw<InvalidOperationException>();
    }

    [Fact]
    public void EnsureCorsAllowlist_accepts_explicit_https_origins()
    {
        var act = () => ProductionStartupGuards.EnsureCorsAllowlist(
            ["https://app.example.com", "http://localhost:3000"]);
        act.Should().NotThrow();
    }

    [Fact]
    public void Validate_accepts_production_when_ops_and_cors_are_set()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Ops:AdminIngestionToken"] = "prod-ops-token",
            ["Cors:AllowedOrigins:0"] = "https://app.example.com",
            ["Cors:AllowedOrigins:1"] = "https://admin.example.com",
        }).Build();

        var act = () => ProductionStartupGuards.Validate(config, new FakeHostEnvironment("Production"));
        act.Should().NotThrow();
    }

    [Fact]
    public void IsHardenedEnvironment_covers_production_and_staging()
    {
        ProductionStartupGuards.IsHardenedEnvironment(new FakeHostEnvironment("Production")).Should().BeTrue();
        ProductionStartupGuards.IsHardenedEnvironment(new FakeHostEnvironment("Staging")).Should().BeTrue();
        ProductionStartupGuards.IsHardenedEnvironment(new FakeHostEnvironment("Development")).Should().BeFalse();
        ProductionStartupGuards.IsHardenedEnvironment(new FakeHostEnvironment("Testing")).Should().BeFalse();
    }

    [Fact]
    public async Task Testing_host_still_allows_any_origin_cors()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
        });

        var client = factory.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Options, "/health");
        request.Headers.Add("Origin", "https://random-dev.example");
        request.Headers.Add("Access-Control-Request-Method", "GET");
        var response = await client.SendAsync(request);

        response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values).Should().BeTrue();
        values!.Should().Contain("*");
    }

    private sealed class FakeHostEnvironment(string name) : IHostEnvironment
    {
        public string EnvironmentName { get; set; } = name;
        public string ApplicationName { get; set; } = "VeriMundi.Tests";
        public string ContentRootPath { get; set; } = AppContext.BaseDirectory;
        public IFileProvider ContentRootFileProvider { get; set; } = new NullFileProvider();
    }
}
