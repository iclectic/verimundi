using System.Diagnostics.Metrics;

namespace VeriMundi.Api.Telemetry;

/// <summary>
/// OpenTelemetry-compatible instruments for product API traffic (Ask, reports, HTTP, rate limits).
/// Exported when Prometheus scrape is enabled.
/// </summary>
public static class ApiTelemetry
{
    public const string MeterName = "VeriMundi.Api";

    private static readonly Meter Meter = new(MeterName, "1.0.0");

    public static readonly Counter<long> HttpRequests =
        Meter.CreateCounter<long>(
            "verimundi_api_http_requests",
            description: "HTTP requests handled by the API");

    public static readonly Histogram<double> HttpDurationMilliseconds =
        Meter.CreateHistogram<double>(
            "verimundi_api_http_duration_ms",
            unit: "ms",
            description: "HTTP request duration");

    public static readonly Counter<long> AskRequests =
        Meter.CreateCounter<long>(
            "verimundi_api_ask_requests",
            description: "Ask VeriMundi questions answered (including insufficient evidence)");

    public static readonly Counter<long> ReportsAccepted =
        Meter.CreateCounter<long>(
            "verimundi_api_reports_accepted",
            description: "Problem reports accepted for editorial follow-up");

    public static readonly Counter<long> RateLimited =
        Meter.CreateCounter<long>(
            "verimundi_api_rate_limited",
            description: "Requests rejected by rate limit middleware");

    public static void RecordHttp(string method, int statusCode, string routeGroup, double elapsedMs)
    {
        var statusClass = statusCode switch
        {
            >= 500 => "5xx",
            >= 400 => "4xx",
            >= 300 => "3xx",
            >= 200 => "2xx",
            _ => "1xx",
        };
        var tags = new KeyValuePair<string, object?>[]
        {
            new("method", method),
            new("status_class", statusClass),
            new("route_group", routeGroup),
        };
        HttpRequests.Add(1, tags);
        HttpDurationMilliseconds.Record(elapsedMs, tags);
    }

    public static void RecordAsk(bool insufficientEvidence)
    {
        AskRequests.Add(1, new KeyValuePair<string, object?>("insufficient_evidence", insufficientEvidence));
    }

    public static void RecordReportAccepted(string reason)
    {
        ReportsAccepted.Add(1, new KeyValuePair<string, object?>("reason", reason));
    }

    public static void RecordRateLimited(string kind)
    {
        RateLimited.Add(1, new KeyValuePair<string, object?>("kind", kind));
    }

    public static string RouteGroup(string? path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return "unknown";
        }

        if (path.Contains("/questions", StringComparison.OrdinalIgnoreCase))
        {
            return "ask";
        }

        if (path.Contains("/reports", StringComparison.OrdinalIgnoreCase))
        {
            return "reports";
        }

        if (path.StartsWith("/v1/search", StringComparison.OrdinalIgnoreCase))
        {
            return "search";
        }

        if (path.StartsWith("/v1/stories", StringComparison.OrdinalIgnoreCase))
        {
            return "stories";
        }

        if (path.StartsWith("/v1/admin", StringComparison.OrdinalIgnoreCase))
        {
            return "admin";
        }

        if (path.StartsWith("/v1/", StringComparison.OrdinalIgnoreCase))
        {
            return "api";
        }

        if (path.Equals("/health", StringComparison.OrdinalIgnoreCase) ||
            path.Equals("/ready", StringComparison.OrdinalIgnoreCase) ||
            path.Equals("/metrics", StringComparison.OrdinalIgnoreCase))
        {
            return "ops";
        }

        return "other";
    }
}
