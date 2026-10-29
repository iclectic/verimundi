using Microsoft.EntityFrameworkCore;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Telemetry;
using VeriMundi.Application.Safety;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Api.Endpoints;

public static class ReportEndpoints
{
    public static RouteGroupBuilder MapReportEndpoints(this RouteGroupBuilder api)
    {
        api.MapPost("/stories/{storyId}/reports", async (
            string storyId,
            ReportRequest body,
            VeriMundiDbContext db,
            ILoggerFactory loggerFactory) =>
        {
            if (!Guid.TryParse(storyId, out var id))
            {
                return Results.BadRequest(new ApiError("invalid_id", "storyId must be a GUID."));
            }

            if (!StoryReportReasons.TryNormalize(body.Reason, out var reason))
            {
                return Results.BadRequest(new ApiError(
                    "invalid_reason",
                    "Reason must be one of the supported report categories."));
            }

            var details = string.IsNullOrWhiteSpace(body.Details) ? null : body.Details.Trim();
            if (!StoryReportReasons.IsDetailsValid(details))
            {
                return Results.BadRequest(new ApiError(
                    "invalid_details",
                    $"Details must be at most {StoryReportReasons.MaxDetailsLength} characters."));
            }

            var exists = await db.Stories.AsNoTracking().AnyAsync(s => s.Id == id);
            if (!exists)
            {
                return Results.NotFound(new ApiError("story_not_found", "Story was not found."));
            }

            // Accepted for editorial follow-up. Details text is not written to application logs —
            // only length — to reduce accidental PII retention in log sinks.
            var reportId = Guid.NewGuid();
            loggerFactory.CreateLogger("VeriMundi.Reports").LogWarning(
                "Story report received. ReportId={ReportId} StoryId={StoryId} Reason={Reason} DetailsLength={DetailsLength}",
                reportId,
                id,
                reason,
                details?.Length ?? 0);
            ApiTelemetry.RecordReportAccepted(reason);

            return Results.Accepted(
                $"/v1/stories/{storyId}/reports/{reportId}",
                new ReportResponse(reportId.ToString(), DateTimeOffset.UtcNow, "received"));
        });

        return api;
    }
}
