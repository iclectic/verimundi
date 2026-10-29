using FluentAssertions;
using VeriMundi.Api.RateLimiting;

namespace VeriMundi.IntegrationTests;

public class MemoryRateLimiterTests
{
    [Fact]
    public async Task Allows_up_to_limit_then_denies_with_retry_after()
    {
        var limiter = new MemoryRateLimiter();
        var window = TimeSpan.FromMinutes(1);

        for (var i = 0; i < 3; i++)
        {
            var allowed = await limiter.TryAcquireAsync("write", "10.0.0.1", 3, window);
            allowed.IsAllowed.Should().BeTrue();
            allowed.RetryAfterSeconds.Should().BeNull();
        }

        var denied = await limiter.TryAcquireAsync("write", "10.0.0.1", 3, window);
        denied.IsAllowed.Should().BeFalse();
        denied.RetryAfterSeconds.Should().NotBeNull();
        denied.RetryAfterSeconds!.Value.Should().BeInRange(1, 60);
    }

    [Fact]
    public async Task Partitions_and_keys_are_isolated()
    {
        var limiter = new MemoryRateLimiter();
        var window = TimeSpan.FromMinutes(1);

        (await limiter.TryAcquireAsync("write", "a", 1, window)).IsAllowed.Should().BeTrue();
        (await limiter.TryAcquireAsync("write", "a", 1, window)).IsAllowed.Should().BeFalse();

        (await limiter.TryAcquireAsync("write", "b", 1, window)).IsAllowed.Should().BeTrue();
        (await limiter.TryAcquireAsync("ask", "a", 1, window)).IsAllowed.Should().BeTrue();
    }

    [Fact]
    public async Task Separate_instances_do_not_share_counters()
    {
        var a = new MemoryRateLimiter();
        var b = new MemoryRateLimiter();
        var window = TimeSpan.FromMinutes(1);

        (await a.TryAcquireAsync("write", "same", 1, window)).IsAllowed.Should().BeTrue();
        (await a.TryAcquireAsync("write", "same", 1, window)).IsAllowed.Should().BeFalse();
        (await b.TryAcquireAsync("write", "same", 1, window)).IsAllowed.Should().BeTrue();
    }
}
