namespace VeriMundi.Api.Options;

/// <summary>
/// In-app rate-limit knobs. Edge/WAF limits remain recommended; this is defence-in-depth.
/// </summary>
public sealed class RateLimitOptions
{
    public const string SectionName = "RateLimiting";

    /// <summary>
    /// <c>Memory</c> for Development/Testing (and single-instance hosts).
    /// <c>Redis</c> for Staging/Production multi-replica deploys.
    /// Empty → chosen from hosting environment (Memory in Dev/Testing, Redis otherwise).
    /// </summary>
    public string Provider { get; set; } = string.Empty;

    /// <summary>All POST/PUT/DELETE per client IP per minute.</summary>
    public int WritePerMinute { get; set; } = 30;

    /// <summary>Ask VeriMundi (<c>POST …/questions</c>) per client IP per minute.</summary>
    public int AskPerMinute { get; set; } = 10;

    /// <summary>Problem reports (<c>POST …/reports</c>) per client IP per minute.</summary>
    public int ReportPerMinute { get; set; } = 10;

    /// <summary>
    /// Redis connection string when <see cref="Provider"/> is Redis.
    /// Also accepted via <c>ConnectionStrings:Redis</c>.
    /// </summary>
    public string? RedisConnection { get; set; }

    /// <summary>Fixed window length in seconds (default 60).</summary>
    public int WindowSeconds { get; set; } = 60;

    /// <summary>Retry-After header seconds when limited (defaults to <see cref="WindowSeconds"/>).</summary>
    public int RetryAfterSeconds { get; set; } = 60;
}
