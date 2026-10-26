using Microsoft.Extensions.Options;
using OpenTelemetry.Metrics;
using VeriMundi.Api.Options;
using VeriMundi.Infrastructure.Ingestion;

namespace VeriMundi.Api.Telemetry;

public static class VeriMundiTelemetryExtensions
{
    public static WebApplicationBuilder AddVeriMundiTelemetry(this WebApplicationBuilder builder)
    {
        builder.Services.Configure<TelemetryOptions>(
            builder.Configuration.GetSection(TelemetryOptions.SectionName));

        // Always register the meter provider so instruments exist for agents.
        // Prometheus exporter is registered unconditionally but the scrape route
        // is mapped only when Telemetry:EnablePrometheus is true (see Map*).
        builder.Services.AddOpenTelemetry()
            .WithMetrics(metrics =>
            {
                metrics
                    .AddMeter(IngestionTelemetry.MeterName)
                    .AddPrometheusExporter();
            });

        return builder;
    }

    public static WebApplication MapVeriMundiTelemetry(this WebApplication app)
    {
        var options = app.Services.GetRequiredService<IOptions<TelemetryOptions>>().Value;
        if (!IsEnabled(options, app.Configuration))
        {
            return app;
        }

        var path = string.IsNullOrWhiteSpace(options.PrometheusPath)
            ? "/metrics"
            : options.PrometheusPath;
        app.MapPrometheusScrapingEndpoint(path);
        app.Logger.LogInformation(
            "Prometheus metrics scrape enabled at {Path} (meter {Meter})",
            path,
            IngestionTelemetry.MeterName);
        return app;
    }

    public static bool IsEnabled(TelemetryOptions options, IConfiguration configuration)
    {
        if (options.EnablePrometheus)
        {
            return true;
        }

        var envFlag = configuration["Telemetry:EnablePrometheus"]
            ?? configuration["Telemetry__EnablePrometheus"]
            ?? Environment.GetEnvironmentVariable("Telemetry__EnablePrometheus");
        return string.Equals(envFlag, "true", StringComparison.OrdinalIgnoreCase);
    }
}
