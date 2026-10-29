using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using VeriMundi.Api.Options;
using VeriMundi.Api.Security;

namespace VeriMundi.IntegrationTests;

public class OpsAdminAuthTests
{
    [Fact]
    public void ExtractToken_reads_custom_header_and_bearer()
    {
        var viaHeader = new DefaultHttpContext();
        viaHeader.Request.Headers[OpsAdminAuth.HeaderName] = "ops-secret";
        OpsAdminAuth.ExtractToken(viaHeader.Request).Should().Be("ops-secret");

        var viaBearer = new DefaultHttpContext();
        viaBearer.Request.Headers.Authorization = "Bearer ops-secret";
        OpsAdminAuth.ExtractToken(viaBearer.Request).Should().Be("ops-secret");
    }

    [Fact]
    public void FixedTimeEquals_rejects_mismatched_secrets()
    {
        OpsAdminAuth.FixedTimeEquals("abc", "abc").Should().BeTrue();
        OpsAdminAuth.FixedTimeEquals("abc", "abd").Should().BeFalse();
        OpsAdminAuth.FixedTimeEquals("abc", "abcd").Should().BeFalse();
    }

    [Fact]
    public void TryAuthorize_allows_unconfigured_token_in_testing_env()
    {
        var http = new DefaultHttpContext();
        var env = new FakeHostEnvironment("Testing");
        var ok = OpsAdminAuth.TryAuthorize(
            http.Request,
            new OpsAuthOptions { AdminIngestionToken = "" },
            env,
            out var failure);
        ok.Should().BeTrue();
        failure.Should().BeNull();
    }

    [Fact]
    public void TryAuthorize_fails_closed_when_unconfigured_outside_dev()
    {
        var http = new DefaultHttpContext();
        var env = new FakeHostEnvironment("Production");
        var ok = OpsAdminAuth.TryAuthorize(
            http.Request,
            new OpsAuthOptions { AdminIngestionToken = "   " },
            env,
            out var failure);
        ok.Should().BeFalse();
        failure.Should().NotBeNull();
    }

    [Fact]
    public void TryAuthorize_requires_matching_token_when_configured()
    {
        var env = new FakeHostEnvironment("Production");
        var options = new OpsAuthOptions { AdminIngestionToken = "correct-token" };

        var missing = new DefaultHttpContext();
        OpsAdminAuth.TryAuthorize(missing.Request, options, env, out _).Should().BeFalse();

        var wrong = new DefaultHttpContext();
        wrong.Request.Headers[OpsAdminAuth.HeaderName] = "wrong";
        OpsAdminAuth.TryAuthorize(wrong.Request, options, env, out _).Should().BeFalse();

        var right = new DefaultHttpContext();
        right.Request.Headers[OpsAdminAuth.HeaderName] = "correct-token";
        OpsAdminAuth.TryAuthorize(right.Request, options, env, out var failure).Should().BeTrue();
        failure.Should().BeNull();
    }

    [Fact]
    public async Task Admin_ingestion_rejects_missing_ops_token_when_configured()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["Ops:AdminIngestionToken"] = "integration-ops-token"
                });
            });
        });

        var client = factory.CreateClient();
        var response = await client.PostAsync("/v1/admin/ingestion/run", content: null);
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        var json = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(json);
        doc.RootElement.GetProperty("code").GetString().Should().Be("ops_unauthorized");
    }

    [Fact]
    public async Task Admin_ingestion_rejects_wrong_bearer_token()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["Ops:AdminIngestionToken"] = "integration-ops-token"
                });
            });
        });

        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", "not-the-token");
        var response = await client.PostAsync("/v1/admin/ingestion/run", content: null);
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Admin_ingestion_passes_auth_with_header_token()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["Ops:AdminIngestionToken"] = "integration-ops-token"
                });
            });
        });

        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Add(OpsAdminAuth.HeaderName, "integration-ops-token");
        var response = await client.PostAsync("/v1/admin/ingestion/run", content: null);
        // Auth must pass; without Postgres in Testing the pipeline returns 503 instead of throwing.
        response.StatusCode.Should().NotBe(HttpStatusCode.Unauthorized);
        response.StatusCode.Should().BeOneOf(HttpStatusCode.OK, HttpStatusCode.ServiceUnavailable);
        if (response.StatusCode == HttpStatusCode.ServiceUnavailable)
        {
            var json = await response.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(json);
            doc.RootElement.GetProperty("code").GetString().Should().Be("ingestion_unavailable");
        }
    }

    [Fact]
    public async Task Admin_metrics_requires_ops_token_when_configured()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["Ops:AdminIngestionToken"] = "integration-ops-token"
                });
            });
        });

        var client = factory.CreateClient();
        var unauthorized = await client.GetAsync("/v1/admin/ingestion/metrics");
        unauthorized.StatusCode.Should().Be(HttpStatusCode.Unauthorized);

        client.DefaultRequestHeaders.Add(OpsAdminAuth.HeaderName, "integration-ops-token");
        var ok = await client.GetAsync("/v1/admin/ingestion/metrics");
        ok.StatusCode.Should().Be(HttpStatusCode.OK);
        var json = await ok.Content.ReadAsStringAsync();
        json.Should().Contain("cyclesCompleted");
        json.Should().Contain("articlesIngestedTotal");
    }

    private sealed class FakeHostEnvironment(string name) : IHostEnvironment
    {
        public string EnvironmentName { get; set; } = name;
        public string ApplicationName { get; set; } = "VeriMundi.Tests";
        public string ContentRootPath { get; set; } = AppContext.BaseDirectory;
        public Microsoft.Extensions.FileProviders.IFileProvider ContentRootFileProvider { get; set; } =
            new Microsoft.Extensions.FileProviders.NullFileProvider();
    }
}
