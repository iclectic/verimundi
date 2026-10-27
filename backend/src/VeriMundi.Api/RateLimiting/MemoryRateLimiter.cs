using System.Collections.Concurrent;

namespace VeriMundi.Api.RateLimiting;

/// <summary>
/// Process-local fixed-window limiter. Suitable for Development, Testing, and single-instance hosts.
/// Instance-scoped (DI singleton) so WebApplicationFactory hosts do not share static counters.
/// </summary>
public sealed class MemoryRateLimiter : IRateLimiter
{
    private readonly ConcurrentDictionary<string, Counter> _counters = new();

    public Task<RateLimitDecision> TryAcquireAsync(
        string partition,
        string key,
        int limitPerWindow,
        TimeSpan window,
        CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var composite = $"{partition}:{key}";
        var counter = _counters.GetOrAdd(composite, _ => new Counter());
        var limited = false;
        int retryAfter;
        lock (counter)
        {
            var now = DateTimeOffset.UtcNow;
            if (now - counter.WindowStart > window)
            {
                counter.WindowStart = now;
                counter.Count = 0;
            }

            counter.Count++;
            limited = counter.Count > limitPerWindow;
            var elapsed = now - counter.WindowStart;
            var remaining = window - elapsed;
            retryAfter = Math.Max(1, (int)Math.Ceiling(remaining.TotalSeconds));
        }

        return Task.FromResult(limited
            ? new RateLimitDecision(false, retryAfter)
            : new RateLimitDecision(true, null));
    }

    private sealed class Counter
    {
        public DateTimeOffset WindowStart { get; set; } = DateTimeOffset.UtcNow;
        public int Count { get; set; }
    }
}
