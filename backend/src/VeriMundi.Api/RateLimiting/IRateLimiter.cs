namespace VeriMundi.Api.RateLimiting;

/// <summary>
/// Pluggable fixed-window rate limiter. Memory for Dev/Testing; Redis (or shared store) for multi-replica hosts.
/// </summary>
public interface IRateLimiter
{
    /// <summary>
    /// Attempts to consume one permit for <paramref name="partition"/> + <paramref name="key"/>.
    /// </summary>
    Task<RateLimitDecision> TryAcquireAsync(
        string partition,
        string key,
        int limitPerWindow,
        TimeSpan window,
        CancellationToken cancellationToken = default);
}

/// <param name="IsAllowed">True when the request may proceed.</param>
/// <param name="RetryAfterSeconds">Suggested Retry-After when denied; null when allowed.</param>
public sealed record RateLimitDecision(bool IsAllowed, int? RetryAfterSeconds);
