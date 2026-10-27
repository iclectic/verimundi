using Microsoft.EntityFrameworkCore;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Telemetry;
using VeriMundi.Application.Abstractions;
using VeriMundi.Domain;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Api.Endpoints;

public static class AskEndpoints
{
    public static RouteGroupBuilder MapAskEndpoints(this RouteGroupBuilder api)
    {
        api.MapPost("/stories/{storyId}/questions", async (
            string storyId,
            QuestionRequest body,
            VeriMundiDbContext db,
            IAiSynthesisService ai) =>
        {
            if (!Guid.TryParse(storyId, out var id))
            {
                return Results.BadRequest(new ApiError("invalid_id", "storyId must be a GUID."));
            }

            if (string.IsNullOrWhiteSpace(body.Question) || body.Question.Length > 500)
            {
                return Results.BadRequest(new ApiError("invalid_question", "Question must be 1–500 characters."));
            }

            var story = await db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .Include(s => s.Claims)
                .FirstOrDefaultAsync(s => s.Id == id);
            if (story is null)
            {
                return Results.NotFound(new ApiError("story_not_found", "Story was not found."));
            }

            var evidence = story.ArticleLinks.Select(l => new AiSourceEvidence(
                l.ArticleId,
                l.Article!.Id.ToString(),
                l.Article.Source?.Name ?? "source",
                l.Article.Headline,
                l.Article.PermittedExcerpt,
                l.SourceCoverageClass.ToString().ToLowerInvariant())).ToList();

            var facts = story.Claims
                .Where(c => c.Status == ClaimStatus.Confirmed)
                .Select(c => new AiConfirmedFact(c.Text, Array.Empty<string>()))
                .ToList();

            var result = await ai.AnswerQuestionAsync(new AiQuestionRequest(
                story.Id,
                body.Question,
                story.CanonicalHeadline,
                story.ShortSummary,
                evidence,
                facts,
                story.Uncertainties));

            ApiTelemetry.RecordAsk(result.InsufficientEvidence);

            return Results.Ok(new QuestionResponse(
                result.Answer,
                result.InsufficientEvidence,
                result.Confidence,
                result.SourceIds,
                result.Uncertainty,
                result.GeneratedAt));
        });

        return api;
    }
}
