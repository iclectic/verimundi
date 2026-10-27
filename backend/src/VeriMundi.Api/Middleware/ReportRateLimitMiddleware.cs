using System.Collections.Concurrent;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Telemetry;

namespace VeriMundi.Api.Middleware;

/// <summary>
/// Stricter per-IP limit for story problem reports to reduce abuse/spam.
/// Runs in addition to the global write rate limiter.
/// </summary>
public sealed class ReportRateLimitMiddleware(RequestDelegate next)
{
    private static readonly ConcurrentDictionary<string, Counter> Counters = new();
    private static readonly TimeSpan Window = TimeSpan.FromMinutes(1);
    private const int Limit = 10;

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value ?? string.Empty;
        var isReport = HttpMethods.IsPost(context.Request.Method) &&
                       path.Contains("/reports", StringComparison.OrdinalIgnoreCase);
        if (!isReport)
        {
            await next(context);
            return;
        }

        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var counter = Counters.GetOrAdd(key, _ => new Counter());
        var limited = false;
        lock (counter)
        {
            var now = DateTimeOffset.UtcNow;
            if (now - counter.WindowStart > Window)
            {
                counter.WindowStart = now;
                counter.Count = 0;
            }

            counter.Count++;
            limited = counter.Count > Limit;
        }

        if (limited)
        {
            ApiTelemetry.RecordRateLimited("report");
            context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.Response.Headers.RetryAfter = "60";
            await context.Response.WriteAsJsonAsync(new ApiError(
                "report_rate_limited",
                "Too many problem reports. Please wait a minute and try again."));
            return;
        }

        await next(context);
    }

    private sealed class Counter
    {
        public DateTimeOffset WindowStart { get; set; } = DateTimeOffset.UtcNow;
        public int Count { get; set; }
    }
}
