using StackExchange.Redis;

namespace VeriMundi.Api.RateLimiting;

/// <summary>
/// Shared fixed-window limiter backed by Redis. Use for Staging/Production multi-replica deploys.
/// </summary>
public sealed class RedisRateLimiter(IConnectionMultiplexer multiplexer) : IRateLimiter
{
    private readonly IDatabase _db = multiplexer.GetDatabase();

    public async Task<RateLimitDecision> TryAcquireAsync(
        string partition,
        string key,
        int limitPerWindow,
        TimeSpan window,
        CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var windowSeconds = Math.Max(1, (int)Math.Ceiling(window.TotalSeconds));
        var bucket = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / windowSeconds;
        var redisKey = $"verimundi:rl:{partition}:{key}:{bucket}";

        var count = await _db.StringIncrementAsync(redisKey).ConfigureAwait(false);
        if (count == 1)
        {
            await _db.KeyExpireAsync(redisKey, window).ConfigureAwait(false);
        }

        if (count > limitPerWindow)
        {
            var ttl = await _db.KeyTimeToLiveAsync(redisKey).ConfigureAwait(false);
            var retryAfter = ttl is { } remaining && remaining > TimeSpan.Zero
                ? Math.Max(1, (int)Math.Ceiling(remaining.TotalSeconds))
                : windowSeconds;
            return new RateLimitDecision(false, retryAfter);
        }

        return new RateLimitDecision(true, null);
    }
}
