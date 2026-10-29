using Microsoft.EntityFrameworkCore;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Mapping;
using VeriMundi.Api.OpenApi;
using VeriMundi.Application.Scoring;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Api.Endpoints;

public static class StoriesEndpoints
{
    public static RouteGroupBuilder MapStoriesEndpoints(this RouteGroupBuilder api)
    {
        api.MapGet("/stories", async (
            VeriMundiDbContext db,
            string? query,
            string? region,
            string? countryCode,
            string? category,
            string? severity,
            string? tone,
            string? verification,
            bool? hasLocalCoverage,
            int page = 1,
            int pageSize = 20) =>
        {
            (page, pageSize) = EndpointHelpers.NormalizePaging(page, pageSize);

            var stories = await db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .Include(s => s.Claims).ThenInclude(c => c.Evidence)
                .Where(s => s.Status == StoryStatus.Active)
                .ToListAsync();

            IEnumerable<StoryCluster> filtered = stories;
            if (!string.IsNullOrWhiteSpace(query))
            {
                var q = query.Trim().ToLowerInvariant();
                filtered = filtered.Where(s =>
                    s.CanonicalHeadline.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                    s.ShortSummary.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                    s.Region.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                    s.PrimaryCountryCode.Contains(q, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(region))
            {
                filtered = filtered.Where(s => s.Region.Equals(region, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(countryCode))
            {
                filtered = filtered.Where(s =>
                    s.PrimaryCountryCode.Equals(countryCode, StringComparison.OrdinalIgnoreCase) ||
                    s.AffectedCountryCodes.Any(c => c.Equals(countryCode, StringComparison.OrdinalIgnoreCase)));
            }

            if (!string.IsNullOrWhiteSpace(category) && Enum.TryParse<StoryCategory>(category, true, out var cat))
            {
                filtered = filtered.Where(s => s.Category == cat);
            }

            if (!string.IsNullOrWhiteSpace(severity) && Enum.TryParse<Severity>(severity, true, out var sev))
            {
                filtered = filtered.Where(s => s.Severity == sev);
            }

            if (!string.IsNullOrWhiteSpace(tone) && Enum.TryParse<Tone>(tone, true, out var tn))
            {
                filtered = filtered.Where(s => s.Tone == tn);
            }

            if (!string.IsNullOrWhiteSpace(verification) && Enum.TryParse<VerificationStatus>(verification, true, out var ver))
            {
                filtered = filtered.Where(s => s.VerificationStatus == ver);
            }

            if (hasLocalCoverage == true)
            {
                filtered = filtered.Where(s => s.LocalSourceCount > 0);
            }

            var ranked = WorldPulseRanker.RankWithRegionalBalance(filtered, take: 500);
            var total = ranked.Count;
            var pageItems = ranked.Skip((page - 1) * pageSize).Take(pageSize).Select(s => StoryMapper.ToDto(s)).ToList();
            return Results.Ok(new PagedResponse<StoryDto>(pageItems, page, pageSize, total));
        })
        .WithName("ListStories")
        .WithTags("Stories")
        .WithStoryPageContract();

        api.MapGet("/stories/underreported", async (VeriMundiDbContext db, int page = 1, int pageSize = 20) =>
        {
            (page, pageSize) = EndpointHelpers.NormalizePaging(page, pageSize);
            var stories = await db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .Include(s => s.Claims).ThenInclude(c => c.Evidence)
                .Where(s => s.Status == StoryStatus.Active)
                .OrderByDescending(s => s.UnderreportedScore)
                .ToListAsync();
            var total = stories.Count;
            var items = stories.Skip((page - 1) * pageSize).Take(pageSize).Select(s => StoryMapper.ToDto(s)).ToList();
            return Results.Ok(new PagedResponse<StoryDto>(items, page, pageSize, total));
        });

        api.MapGet("/stories/positive", async (VeriMundiDbContext db, int page = 1, int pageSize = 20) =>
        {
            (page, pageSize) = EndpointHelpers.NormalizePaging(page, pageSize);
            var stories = await db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .Include(s => s.Claims).ThenInclude(c => c.Evidence)
                .Where(s => s.Status == StoryStatus.Active && (s.Tone == Tone.Positive || s.PositiveImpactScore >= 40))
                .OrderByDescending(s => s.PositiveImpactScore)
                .ToListAsync();
            var total = stories.Count;
            var items = stories.Skip((page - 1) * pageSize).Take(pageSize).Select(s => StoryMapper.ToDto(s)).ToList();
            return Results.Ok(new PagedResponse<StoryDto>(items, page, pageSize, total));
        });

        api.MapGet("/stories/{storyId}", async (string storyId, VeriMundiDbContext db) =>
        {
            if (!Guid.TryParse(storyId, out var id))
            {
                return Results.BadRequest(new ApiError("invalid_id", "storyId must be a GUID."));
            }

            var story = await db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .Include(s => s.Claims).ThenInclude(c => c.Evidence)
                .FirstOrDefaultAsync(s => s.Id == id);
            return story is null
                ? Results.NotFound(new ApiError("story_not_found", "Story was not found."))
                : Results.Ok(StoryMapper.ToDto(story));
        })
        .WithName("GetStoryById")
        .WithTags("Stories")
        .WithStoryItemContract();

        api.MapGet("/stories/{storyId}/sources", async (string storyId, VeriMundiDbContext db) =>
        {
            if (!Guid.TryParse(storyId, out var id))
            {
                return Results.BadRequest(new ApiError("invalid_id", "storyId must be a GUID."));
            }

            var story = await db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .FirstOrDefaultAsync(s => s.Id == id);
            if (story is null)
            {
                return Results.NotFound(new ApiError("story_not_found", "Story was not found."));
            }

            return Results.Ok(StoryMapper.ToDto(story).SourceArticles);
        });

        api.MapGet("/stories/{storyId}/claims", async (string storyId, VeriMundiDbContext db) =>
        {
            if (!Guid.TryParse(storyId, out var id))
            {
                return Results.BadRequest(new ApiError("invalid_id", "storyId must be a GUID."));
            }

            var claims = await db.Claims.AsNoTracking()
                .Where(c => c.StoryId == id)
                .Select(c => new ClaimDto(
                    c.Id.ToString(),
                    c.Text,
                    c.Status.ToString(),
                    c.Confidence,
                    c.FirstObservedAt,
                    c.LastObservedAt))
                .ToListAsync();
            return Results.Ok(claims);
        });

        api.MapGet("/stories/{storyId}/history", async (string storyId, VeriMundiDbContext db) =>
        {
            if (!Guid.TryParse(storyId, out var id))
            {
                return Results.BadRequest(new ApiError("invalid_id", "storyId must be a GUID."));
            }

            var story = await db.Stories.AsNoTracking().FirstOrDefaultAsync(s => s.Id == id);
            if (story is null)
            {
                return Results.NotFound(new ApiError("story_not_found", "Story was not found."));
            }

            var history = new[]
            {
                new
                {
                    at = story.FirstPublishedAt,
                    eventType = "first_published",
                    summary = story.CanonicalHeadline
                },
                new
                {
                    at = story.GeneratedAt,
                    eventType = "synthesis",
                    summary = story.ShortSummary
                },
                new
                {
                    at = story.LastUpdatedAt,
                    eventType = "last_updated",
                    summary = story.RankingReason
                }
            };
            return Results.Ok(history);
        });

        return api;
    }
}
