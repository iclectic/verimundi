namespace VeriMundi.Api.Options;

/// <summary>
/// Optional OpenTelemetry / Prometheus export. Off by default.
/// </summary>
public sealed class TelemetryOptions
{
    public const string SectionName = "Telemetry";

    /// <summary>When true, maps GET /metrics for Prometheus scraping.</summary>
    public bool EnablePrometheus { get; set; }

    /// <summary>Optional scrape path (default /metrics).</summary>
    public string PrometheusPath { get; set; } = "/metrics";
}
