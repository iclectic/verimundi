using System.Net;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using VeriMundi.Api.Telemetry;
using VeriMundi.Infrastructure.Ingestion;

namespace VeriMundi.IntegrationTests;

public class PrometheusMetricsTests
{
    [Fact]
    public async Task Metrics_endpoint_absent_when_prometheus_disabled()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseSetting("Telemetry:EnablePrometheus", "false");
            builder.UseSetting(WebHostDefaults.EnvironmentKey, "Testing");
        });

        var client = factory.CreateClient();
        var response = await client.GetAsync("/metrics");
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Metrics_endpoint_exposes_ingestion_meter_when_enabled()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseSetting(WebHostDefaults.EnvironmentKey, "Testing");
            builder.ConfigureAppConfiguration((_, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["Telemetry:EnablePrometheus"] = "true",
                    ["Telemetry:PrometheusPath"] = "/metrics"
                });
            });
        });

        // Emit at least one sample so the meter appears in the scrape.
        var store = factory.Services.GetRequiredService<IngestionMetricsStore>();
        var now = DateTimeOffset.UtcNow;
        store.RecordSuccess(new IngestionResult(
            ArticlesIngested: 2,
            ClusterOperations: 2,
            ClustersCreated: 1,
            ClustersAttached: 1,
            DuplicatesSkipped: 0,
            UnapprovedSkipped: 0,
            RestrictedSkipped: 0,
            ProviderFailures: 0,
            ProvidersAttempted: 1,
            ArticlesFetched: 2,
            ProposedSourcesCreated: 0,
            SynthesesRun: 1,
            DurationMs: 15,
            StartedAt: now,
            CompletedAt: now.AddMilliseconds(15),
            Trigger: "test"));

        ApiTelemetry.RecordAsk(insufficientEvidence: false);
        ApiTelemetry.RecordReportAccepted("Other");
        ApiTelemetry.RecordRateLimited("ask");
        ApiTelemetry.RecordHttp("GET", 200, "ops", 12);

        var client = factory.CreateClient();
        var response = await client.GetAsync("/metrics");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadAsStringAsync();
        body.Should().Contain("verimundi_ingestion_cycles_completed");
        body.Should().Contain("verimundi_ingestion_articles_ingested");
        body.Should().Contain("verimundi_api_ask_requests");
        body.Should().Contain("verimundi_api_reports_accepted");
        body.Should().Contain("verimundi_api_rate_limited");
        body.Should().Contain("verimundi_api_http_requests");
    }
}
