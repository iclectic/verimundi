using Microsoft.Extensions.Options;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Options;
using VeriMundi.Api.RateLimiting;
using VeriMundi.Api.Telemetry;

namespace VeriMundi.Api.Middleware;

/// <summary>
/// Per-IP rate limiter for abuse prevention on write endpoints.
/// Backed by <see cref="IRateLimiter"/> (memory or Redis). Not a substitute for edge/WAF controls.
/// </summary>
public sealed class SimpleRateLimitMiddleware(
    RequestDelegate next,
    IRateLimiter rateLimiter,
    IOptions<RateLimitOptions> options)
{
    public async Task InvokeAsync(HttpContext context)
    {
        if (HttpMethods.IsPost(context.Request.Method) ||
            HttpMethods.IsPut(context.Request.Method) ||
            HttpMethods.IsDelete(context.Request.Method))
        {
            var opts = options.Value;
            var limit = Math.Clamp(opts.WritePerMinute, 1, 10_000);
            var window = TimeSpan.FromSeconds(Math.Clamp(opts.WindowSeconds, 1, 3600));
            var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var decision = await rateLimiter.TryAcquireAsync("write", key, limit, window, context.RequestAborted);
            if (!decision.IsAllowed)
            {
                ApiTelemetry.RecordRateLimited("write");
                context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
                context.Response.Headers.RetryAfter =
                    (decision.RetryAfterSeconds ?? opts.RetryAfterSeconds).ToString();
                await context.Response.WriteAsJsonAsync(new ApiError(
                    "rate_limited",
                    "Too many requests. Please wait a minute and try again."));
                return;
            }
        }

        await next(context);
    }
}
