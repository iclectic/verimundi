using System.Collections.Concurrent;
using Microsoft.Extensions.Options;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Telemetry;
using VeriMundi.Infrastructure.Ai;

namespace VeriMundi.Api.Middleware;

/// <summary>
/// Stricter per-IP limit for Ask VeriMundi (<c>POST .../questions</c>) to control GenAI cost/abuse.
/// Runs in addition to the global write rate limiter.
/// </summary>
public sealed class AskRateLimitMiddleware(RequestDelegate next, IOptions<AiOptions> options)
{
    private static readonly ConcurrentDictionary<string, Counter> Counters = new();
    private static readonly TimeSpan Window = TimeSpan.FromMinutes(1);

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value ?? string.Empty;
        var isAsk = HttpMethods.IsPost(context.Request.Method) &&
                    path.Contains("/questions", StringComparison.OrdinalIgnoreCase);
        if (!isAsk)
        {
            await next(context);
            return;
        }

        var limit = Math.Clamp(options.Value.AskPerMinutePerIp, 1, 120);
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
            limited = counter.Count > limit;
        }

        if (limited)
        {
            ApiTelemetry.RecordRateLimited("ask");
            context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.Response.Headers.RetryAfter = "60";
            await context.Response.WriteAsJsonAsync(new ApiError(
                "ask_rate_limited",
                "Too many Ask VeriMundi requests. Please wait a minute and try again."));
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
