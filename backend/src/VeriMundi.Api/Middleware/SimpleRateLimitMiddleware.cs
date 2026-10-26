using System.Collections.Concurrent;
using VeriMundi.Api.Contracts;

namespace VeriMundi.Api.Middleware;

/// <summary>
/// Lightweight per-IP rate limiter for abuse prevention on write endpoints.
/// Not a substitute for edge/WAF controls in production hosting.
/// </summary>
public sealed class SimpleRateLimitMiddleware(RequestDelegate next)
{
    private static readonly ConcurrentDictionary<string, Counter> Counters = new();
    private static readonly TimeSpan Window = TimeSpan.FromMinutes(1);
    private const int Limit = 30;

    public async Task InvokeAsync(HttpContext context)
    {
        if (HttpMethods.IsPost(context.Request.Method) ||
            HttpMethods.IsPut(context.Request.Method) ||
            HttpMethods.IsDelete(context.Request.Method))
        {
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
                context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
                context.Response.Headers.RetryAfter = "60";
                await context.Response.WriteAsJsonAsync(new ApiError(
                    "rate_limited",
                    "Too many requests. Please wait a minute and try again."));
                return;
            }
        }

        await next(context);
    }

    private sealed class Counter
    {
        public DateTimeOffset WindowStart { get; set; } = DateTimeOffset.UtcNow;
        public int Count { get; set; }
    }
}
