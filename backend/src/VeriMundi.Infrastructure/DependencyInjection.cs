using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
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

        services.AddHttpClient("ingestion", client =>
        {
            client.Timeout = TimeSpan.FromSeconds(30);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("VeriMundiBot/0.1 (+https://github.com/iclectic/verimundi)");
        });

        services.AddSingleton<StoryClusteringService>();
        services.AddScoped<IAiSynthesisService, HeuristicAiSynthesisService>();

        var fixturePath = configuration["Ingestion:FixturePath"];
        services.AddScoped<FixtureNewsProvider>(_ => new FixtureNewsProvider(fixturePath));
        services.AddScoped<RssNewsProvider>();
        services.AddScoped<INewsProvider>(sp => sp.GetRequiredService<FixtureNewsProvider>());
        if (string.Equals(configuration["Ingestion:EnableRss"], "true", StringComparison.OrdinalIgnoreCase))
        {
            services.AddScoped<INewsProvider>(sp => sp.GetRequiredService<RssNewsProvider>());
        }

        services.AddScoped<IngestionPipeline>();

        return services;
    }
}
