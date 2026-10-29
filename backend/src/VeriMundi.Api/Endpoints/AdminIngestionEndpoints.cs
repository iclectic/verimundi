using VeriMundi.Api.Contracts;
using VeriMundi.Api.Options;
using VeriMundi.Api.Security;
using VeriMundi.Infrastructure.Ingestion;

namespace VeriMundi.Api.Endpoints;

public static class AdminIngestionEndpoints
{
    public static RouteGroupBuilder MapAdminIngestionEndpoints(this RouteGroupBuilder api)
    {
        api.MapPost("/admin/ingestion/run", async (
            HttpRequest request,
            IngestionPipeline pipeline,
            IngestionMetricsStore metrics,
            Microsoft.Extensions.Options.IOptions<OpsAuthOptions> opsOptions,
            IHostEnvironment env) =>
        {
            if (!OpsAdminAuth.TryAuthorize(request, opsOptions.Value, env, out var failure))
            {
                return failure!;
            }

            try
            {
                var result = await pipeline.RunAsync(trigger: "admin");
                return Results.Ok(result);
            }
            catch (Exception ex)
            {
                metrics.RecordFailure("admin", ex);
                return Results.Json(
                    new ApiError(
                        "ingestion_unavailable",
                        "Ingestion pipeline failed.",
                        Detail: ex.GetType().Name),
                    statusCode: StatusCodes.Status503ServiceUnavailable);
            }
        });

        api.MapGet("/admin/ingestion/metrics", (
            HttpRequest request,
            IngestionMetricsStore metrics,
            Microsoft.Extensions.Options.IOptions<OpsAuthOptions> opsOptions,
            IHostEnvironment env) =>
        {
            if (!OpsAdminAuth.TryAuthorize(request, opsOptions.Value, env, out var failure))
            {
                return failure!;
            }

            return Results.Ok(metrics.Snapshot());
        });

        return api;
    }
}
