using StackExchange.Redis;
using VeriMundi.Api.Options;

namespace VeriMundi.Api.RateLimiting;

public static class RateLimitingServiceCollectionExtensions
{
    public static IServiceCollection AddVeriMundiRateLimiting(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        services.Configure<RateLimitOptions>(configuration.GetSection(RateLimitOptions.SectionName));
        services.PostConfigure<RateLimitOptions>(opts =>
        {
            // Bridge legacy Ai:AskPerMinutePerIp when RateLimiting:AskPerMinute is unset.
            var rateSection = configuration.GetSection(RateLimitOptions.SectionName);
            if (string.IsNullOrEmpty(rateSection["AskPerMinute"]))
            {
                var legacy = configuration.GetValue<int?>("Ai:AskPerMinutePerIp");
                if (legacy is int n and > 0)
                {
                    opts.AskPerMinute = n;
                }
            }

            if (string.IsNullOrWhiteSpace(opts.RedisConnection))
            {
                opts.RedisConnection = configuration.GetConnectionString("Redis");
            }

            if (string.IsNullOrWhiteSpace(opts.Provider))
            {
                opts.Provider = PreferRedis(environment) ? "Redis" : "Memory";
            }
        });

        var provider = ResolveProvider(configuration, environment);
        if (string.Equals(provider, "Redis", StringComparison.OrdinalIgnoreCase))
        {
            var redisConnection = configuration.GetSection(RateLimitOptions.SectionName)["RedisConnection"]
                ?? configuration.GetConnectionString("Redis");
            if (string.IsNullOrWhiteSpace(redisConnection))
            {
                throw new InvalidOperationException(
                    "RateLimiting:Provider is Redis but no Redis connection was configured. " +
                    "Set RateLimiting:RedisConnection or ConnectionStrings:Redis, " +
                    "or set RateLimiting:Provider=Memory for single-instance hosts.");
            }

            services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect(redisConnection));
            services.AddSingleton<IRateLimiter, RedisRateLimiter>();
        }
        else
        {
            services.AddSingleton<IRateLimiter, MemoryRateLimiter>();
        }

        return services;
    }

    private static bool PreferRedis(IHostEnvironment environment) =>
        environment.IsProduction() ||
        environment.IsStaging() ||
        string.Equals(environment.EnvironmentName, "Staging", StringComparison.OrdinalIgnoreCase);

    private static string ResolveProvider(IConfiguration configuration, IHostEnvironment environment)
    {
        var configured = configuration.GetSection(RateLimitOptions.SectionName)["Provider"];
        if (!string.IsNullOrWhiteSpace(configured))
        {
            return configured.Trim();
        }

        return PreferRedis(environment) ? "Redis" : "Memory";
    }
}
