using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Clustering;
using VeriMundi.Infrastructure.Ai;
using VeriMundi.Infrastructure.Ingestion;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddVeriMundiInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("VeriMundi")
            ?? "Host=localhost;Port=5432;Database=verimundi;Username=verimundi;Password=verimundi";

        services.AddDbContext<VeriMundiDbContext>(options =>
            options.UseNpgsql(connectionString));

        services.Configure<AiOptions>(configuration.GetSection(AiOptions.SectionName));
        services.PostConfigure<AiOptions>(opts =>
        {
            // Prefer dedicated Ai__ApiKey; allow OPENAI_API_KEY as a common alias. Never log the value.
            if (string.IsNullOrWhiteSpace(opts.ApiKey))
            {
                var alias = configuration["OPENAI_API_KEY"]
                    ?? Environment.GetEnvironmentVariable("OPENAI_API_KEY");
                if (!string.IsNullOrWhiteSpace(alias))
                {
                    opts.ApiKey = alias;
                }
            }
        });

        services.AddHttpClient("ingestion", client =>
        {
            client.Timeout = TimeSpan.FromSeconds(30);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("VeriMundiBot/0.1 (+https://github.com/iclectic/verimundi)");
        });

        services.AddHttpClient("ai", (sp, client) =>
        {
            var opts = sp.GetRequiredService<IOptions<AiOptions>>().Value;
            var baseUrl = string.IsNullOrWhiteSpace(opts.BaseUrl)
                ? "https://api.openai.com/v1"
                : opts.BaseUrl.TrimEnd('/') + "/";
            client.BaseAddress = new Uri(baseUrl, UriKind.Absolute);
            client.Timeout = TimeSpan.FromSeconds(Math.Clamp(opts.TimeoutSeconds, 5, 120));
            client.DefaultRequestHeaders.UserAgent.ParseAdd("VeriMundiBot/0.1 (+https://github.com/iclectic/verimundi)");
        });

        services.AddSingleton<StoryClusteringService>();
        services.AddSingleton<IngestionMetricsStore>();
        services.AddScoped<HeuristicAiSynthesisService>();
        services.AddScoped<OpenAiCompatibleSynthesisService>();
        services.AddScoped<IAiSynthesisService>(sp =>
        {
            var opts = sp.GetRequiredService<IOptions<AiOptions>>().Value;
            return opts.IsConfigured
                ? sp.GetRequiredService<OpenAiCompatibleSynthesisService>()
                : sp.GetRequiredService<HeuristicAiSynthesisService>();
        });

        var fixturePath = configuration["Ingestion:FixturePath"];
        services.AddScoped<FixtureNewsProvider>(_ => new FixtureNewsProvider(fixturePath));
        services.AddScoped<RssNewsProvider>();
        services.AddScoped<GdeltDiscoveryProvider>();
        services.AddScoped<INewsProvider>(sp => sp.GetRequiredService<FixtureNewsProvider>());
        if (string.Equals(configuration["Ingestion:EnableRss"], "true", StringComparison.OrdinalIgnoreCase))
        {
            services.AddScoped<INewsProvider>(sp => sp.GetRequiredService<RssNewsProvider>());
        }

        if (string.Equals(configuration["Ingestion:EnableGdelt"], "true", StringComparison.OrdinalIgnoreCase))
        {
            services.AddScoped<INewsProvider>(sp => sp.GetRequiredService<GdeltDiscoveryProvider>());
        }

        services.AddScoped<IngestionPipeline>();

        return services;
    }
}
