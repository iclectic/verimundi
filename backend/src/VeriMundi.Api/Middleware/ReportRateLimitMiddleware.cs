using Microsoft.Extensions.Options;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Options;
using VeriMundi.Api.RateLimiting;
using VeriMundi.Api.Telemetry;

namespace VeriMundi.Api.Middleware;

/// <summary>
/// Stricter per-IP limit for story problem reports to reduce abuse/spam.
/// Runs in addition to the global write rate limiter.
/// </summary>
public sealed class ReportRateLimitMiddleware(
    RequestDelegate next,
    IRateLimiter rateLimiter,
    IOptions<RateLimitOptions> options)
{
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

        var opts = options.Value;
        var limit = Math.Clamp(opts.ReportPerMinute, 1, 120);
        var window = TimeSpan.FromSeconds(Math.Clamp(opts.WindowSeconds, 1, 3600));
        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var decision = await rateLimiter.TryAcquireAsync("report", key, limit, window, context.RequestAborted);
        if (!decision.IsAllowed)
        {
            ApiTelemetry.RecordRateLimited("report");
            context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.Response.Headers.RetryAfter =
                (decision.RetryAfterSeconds ?? opts.RetryAfterSeconds).ToString();
            await context.Response.WriteAsJsonAsync(new ApiError(
                "report_rate_limited",
                "Too many problem reports. Please wait a minute and try again."));
            return;
        }

        await next(context);
    }
}
