using VeriMundi.Api.Options;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Api.Endpoints;

public static class AppConfigHealthEndpoints
{
    public static WebApplication MapAppConfigHealthEndpoints(this WebApplication app)
    {
        app.MapGet("/health", () => Results.Ok(new
        {
            status = "ok",
            at = DateTimeOffset.UtcNow
        }));

        app.MapGet("/ready", async (VeriMundiDbContext db) =>
        {
            try
            {
                var canConnect = await db.Database.CanConnectAsync();
                if (!canConnect)
                {
                    return Results.Json(
                        new { status = "not_ready", reason = "database_unreachable", at = DateTimeOffset.UtcNow },
                        statusCode: StatusCodes.Status503ServiceUnavailable);
                }

                return Results.Ok(new { status = "ready", at = DateTimeOffset.UtcNow });
            }
            catch (Exception ex)
            {
                return Results.Json(
                    new { status = "not_ready", reason = ex.GetType().Name, at = DateTimeOffset.UtcNow },
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }
        });

        return app;
    }

    public static RouteGroupBuilder MapAppConfigEndpoints(this RouteGroupBuilder api)
    {
        api.MapGet("/app/config", (
            Microsoft.Extensions.Options.IOptions<AppOptions> options,
            Microsoft.Extensions.Options.IOptions<VeriMundi.Infrastructure.Ai.AiOptions> aiOptions,
            IHostEnvironment env,
            IConfiguration configuration) =>
        {
            var appOptions = options.Value;
            return Results.Ok(new
            {
                environment = env.EnvironmentName,
                maintenanceMode = appOptions.MaintenanceMode,
                maintenanceMessage = appOptions.MaintenanceMessage,
                minimumAppVersion = appOptions.MinimumAppVersion,
                ingestion = new
                {
                    enableRss = string.Equals(configuration["Ingestion:EnableRss"], "true", StringComparison.OrdinalIgnoreCase),
                    enableGdelt = string.Equals(configuration["Ingestion:EnableGdelt"], "true", StringComparison.OrdinalIgnoreCase)
                },
                ai = new
                {
                    // Never expose keys — only which backend path is active.
                    provider = aiOptions.Value.EffectiveProvider
                },
                disclaimer =
                    "VeriMundi is designed to broaden regional and source visibility. Story selection, classification and AI-generated summaries remain imperfect and should be considered alongside the original reporting."
            });
        });

        return api;
    }
}
