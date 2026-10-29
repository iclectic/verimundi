using Microsoft.Extensions.Options;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Options;
using VeriMundi.Api.RateLimiting;
using VeriMundi.Api.Telemetry;

namespace VeriMundi.Api.Middleware;

/// <summary>
/// Stricter per-IP limit for Ask VeriMundi (<c>POST .../questions</c>) to control GenAI cost/abuse.
/// Runs in addition to the global write rate limiter.
/// </summary>
public sealed class AskRateLimitMiddleware(
    RequestDelegate next,
    IRateLimiter rateLimiter,
    IOptions<RateLimitOptions> options)
{
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

        var opts = options.Value;
        var limit = Math.Clamp(opts.AskPerMinute, 1, 120);
        var window = TimeSpan.FromSeconds(Math.Clamp(opts.WindowSeconds, 1, 3600));
        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var decision = await rateLimiter.TryAcquireAsync("ask", key, limit, window, context.RequestAborted);
        if (!decision.IsAllowed)
        {
            ApiTelemetry.RecordRateLimited("ask");
            context.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            context.Response.Headers.RetryAfter =
                (decision.RetryAfterSeconds ?? opts.RetryAfterSeconds).ToString();
            await context.Response.WriteAsJsonAsync(new ApiError(
                "ask_rate_limited",
                "Too many Ask VeriMundi requests. Please wait a minute and try again."));
            return;
        }

        await next(context);
    }
}
