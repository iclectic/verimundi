using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using VeriMundi.Infrastructure.Ingestion;

namespace VeriMundi.Workers;

public sealed class IngestionHostedService(
    IServiceScopeFactory scopeFactory,
    IngestionMetricsStore metrics,
    ILogger<IngestionHostedService> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // Initial delay so migrations/seed can finish.
        await Task.Delay(TimeSpan.FromSeconds(3), stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = scopeFactory.CreateScope();
                var pipeline = scope.ServiceProvider.GetRequiredService<IngestionPipeline>();
                var result = await pipeline.RunAsync(stoppingToken, trigger: "hosted");
                logger.LogInformation(
                    "Hosted ingestion cycle recorded. Articles={Articles} DurationMs={DurationMs} Failures={Failures}",
                    result.ArticlesIngested,
                    result.DurationMs,
                    result.ProviderFailures);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                metrics.RecordFailure("hosted", ex);
                logger.LogError(ex, "Ingestion cycle failed");
            }

            await Task.Delay(TimeSpan.FromMinutes(15), stoppingToken);
        }
    }
}
