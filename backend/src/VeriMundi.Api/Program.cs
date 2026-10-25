using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Mapping;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Scoring;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;
using VeriMundi.Infrastructure;
using VeriMundi.Infrastructure.Ingestion;
using VeriMundi.Infrastructure.Persistence;
using VeriMundi.Api.Middleware;
using VeriMundi.Workers;

var builder = WebApplication.CreateBuilder(args);

var fixturePath = Path.Combine(builder.Environment.ContentRootPath, "Fixtures", "seed_articles.json");
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
{
    ["Ingestion:FixturePath"] = fixturePath
});

builder.Services.AddVeriMundiInfrastructure(builder.Configuration);
var isTesting = builder.Environment.IsEnvironment("Testing");
if (!isTesting)
{
    builder.Services.AddHostedService<IngestionHostedService>();
}
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.CamelCase));
});
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin());
});

var app = builder.Build();

app.UseCors();
app.UseMiddleware<SimpleRateLimitMiddleware>();
app.Use(async (context, next) =>
{
    var started = DateTimeOffset.UtcNow;
    await next();
    var elapsed = DateTimeOffset.UtcNow - started;
    app.Logger.LogInformation(
        "HTTP {Method} {Path} => {StatusCode} in {ElapsedMs}ms",
        context.Request.Method,
        context.Request.Path.Value,
        context.Response.StatusCode,
        elapsed.TotalMilliseconds);
});
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// WebApplicationFactory smoke tests set Environment=Testing and must not require Postgres.
if (!app.Environment.IsEnvironment("Testing"))
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<VeriMundiDbContext>();
    await SeedData.InitialiseAsync(db);
    var pipeline = scope.ServiceProvider.GetRequiredService<IngestionPipeline>();
    await pipeline.RunAsync();
}

var api = app.MapGroup("/v1");

api.MapGet("/world/status", async (VeriMundiDbContext db, IHostEnvironment env) =>
{
    var active = await db.Stories.CountAsync(s => s.Status == StoryStatus.Active);
    var countries = await db.Countries.CountAsync();
    return Results.Ok(new WorldStatusDto(DateTimeOffset.UtcNow, active, countries, env.EnvironmentName));
});

api.MapGet("/regions", () =>
{
    var regions = WorldPulseRanker.Regions
        .Select(r => new RegionDto(r.ToLowerInvariant().Replace(' ', '-'), r, r))
        .ToList();
    return Results.Ok(regions);
});

api.MapGet("/countries", async (VeriMundiDbContext db) =>
{
    var countries = await db.Countries.AsNoTracking().ToListAsync();
    var stories = await db.Stories.AsNoTracking()
        .Where(s => s.Status == StoryStatus.Active)
        .ToListAsync();
    var dtos = countries
        .Select(c => StoryMapper.ToCountryDto(c, stories.Where(s => s.PrimaryCountryCode == c.Code)))
        .ToList();
    return Results.Ok(dtos);
});

api.MapGet("/countries/{countryCode}", async (string countryCode, VeriMundiDbContext db) =>
{
    var country = await db.Countries.AsNoTracking()
        .FirstOrDefaultAsync(c => c.Code == countryCode.ToUpperInvariant());
    if (country is null)
    {
        return Results.NotFound(new ApiError("country_not_found", "Country was not found."));
    }

    var stories = await db.Stories.AsNoTracking()
        .Where(s => s.Status == StoryStatus.Active && s.PrimaryCountryCode == country.Code)
        .ToListAsync();
    return Results.Ok(StoryMapper.ToCountryDto(country, stories));
});

api.MapGet("/countries/{countryCode}/stories", async (string countryCode, VeriMundiDbContext db, int page = 1, int pageSize = 20) =>
{
    page = Math.Max(1, page);
    pageSize = Math.Clamp(pageSize, 1, 100);
    var query = db.Stories.AsNoTracking()
        .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
        .Include(s => s.Claims).ThenInclude(c => c.Evidence)
        .Where(s => s.Status == StoryStatus.Active && s.PrimaryCountryCode == countryCode.ToUpperInvariant())
        .OrderByDescending(s => s.LastUpdatedAt);
    var total = await query.CountAsync();
    var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
    return Results.Ok(new PagedResponse<StoryDto>(items.Select(s => StoryMapper.ToDto(s)).ToList(), page, pageSize, total));
});

api.MapGet("/stories", async (
    VeriMundiDbContext db,
    string? query,
    string? region,
    string? countryCode,
    string? category,
    string? severity,
    string? tone,
    string? verification,
    int page = 1,
    int pageSize = 20) =>
{
    page = Math.Max(1, page);
    pageSize = Math.Clamp(pageSize, 1, 100);

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
        filtered = filtered.Where(s => s.PrimaryCountryCode.Equals(countryCode, StringComparison.OrdinalIgnoreCase));
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

    var ranked = WorldPulseRanker.RankWithRegionalBalance(filtered, take: 500);
    var total = ranked.Count;
    var pageItems = ranked.Skip((page - 1) * pageSize).Take(pageSize).Select(s => StoryMapper.ToDto(s)).ToList();
    return Results.Ok(new PagedResponse<StoryDto>(pageItems, page, pageSize, total));
});

api.MapGet("/stories/underreported", async (VeriMundiDbContext db, int page = 1, int pageSize = 20) =>
{
    page = Math.Max(1, page);
    pageSize = Math.Clamp(pageSize, 1, 100);
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
    page = Math.Max(1, page);
    pageSize = Math.Clamp(pageSize, 1, 100);
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
});

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

api.MapGet("/search", async (
    VeriMundiDbContext db,
    string? q,
    string? region,
    string? countryCode,
    string? category,
    string? severity,
    string? tone,
    int page = 1,
    int pageSize = 20) =>
{
    // Delegate to /stories filter semantics.
    page = Math.Max(1, page);
    pageSize = Math.Clamp(pageSize, 1, 100);
    var stories = await db.Stories.AsNoTracking()
        .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
        .Include(s => s.Claims).ThenInclude(c => c.Evidence)
        .Where(s => s.Status == StoryStatus.Active)
        .ToListAsync();

    IEnumerable<StoryCluster> filtered = stories;
    if (!string.IsNullOrWhiteSpace(q))
    {
        var queryText = q.Trim();
        filtered = filtered.Where(s =>
            s.CanonicalHeadline.Contains(queryText, StringComparison.OrdinalIgnoreCase) ||
            s.ShortSummary.Contains(queryText, StringComparison.OrdinalIgnoreCase) ||
            s.WhyItMatters.Contains(queryText, StringComparison.OrdinalIgnoreCase) ||
            s.ArticleLinks.Any(l =>
                l.Article!.Headline.Contains(queryText, StringComparison.OrdinalIgnoreCase) ||
                (l.Article.Source != null && l.Article.Source.Name.Contains(queryText, StringComparison.OrdinalIgnoreCase))));
    }

    if (!string.IsNullOrWhiteSpace(region))
    {
        filtered = filtered.Where(s => s.Region.Equals(region, StringComparison.OrdinalIgnoreCase));
    }

    if (!string.IsNullOrWhiteSpace(countryCode))
    {
        filtered = filtered.Where(s => s.PrimaryCountryCode.Equals(countryCode, StringComparison.OrdinalIgnoreCase));
    }

    var list = filtered.OrderByDescending(s => s.LastUpdatedAt).ToList();
    var total = list.Count;
    var items = list.Skip((page - 1) * pageSize).Take(pageSize).Select(s => StoryMapper.ToDto(s)).ToList();
    return Results.Ok(new PagedResponse<StoryDto>(items, page, pageSize, total));
});

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

    return Results.Ok(new QuestionResponse(
        result.Answer,
        result.InsufficientEvidence,
        result.Confidence,
        result.SourceIds,
        result.Uncertainty,
        result.GeneratedAt));
});

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

    if (string.IsNullOrWhiteSpace(body.Reason) || body.Reason.Length > 120)
    {
        return Results.BadRequest(new ApiError("invalid_reason", "Reason must be 1–120 characters."));
    }

    if (body.Details is { Length: > 500 })
    {
        return Results.BadRequest(new ApiError("invalid_details", "Details must be at most 500 characters."));
    }

    var exists = await db.Stories.AsNoTracking().AnyAsync(s => s.Id == id);
    if (!exists)
    {
        return Results.NotFound(new ApiError("story_not_found", "Story was not found."));
    }

    var reportId = Guid.NewGuid();
    loggerFactory.CreateLogger("VeriMundi.Reports").LogWarning(
        "Story report received. ReportId={ReportId} StoryId={StoryId} Reason={Reason} DetailsLength={DetailsLength}",
        reportId,
        id,
        body.Reason,
        body.Details?.Length ?? 0);

    return Results.Accepted(
        $"/v1/stories/{storyId}/reports/{reportId}",
        new ReportResponse(reportId.ToString(), DateTimeOffset.UtcNow, "received"));
});

api.MapPost("/admin/ingestion/run", async (IngestionPipeline pipeline) =>
{
    var result = await pipeline.RunAsync();
    return Results.Ok(result);
});

app.MapGet("/health", () => Results.Ok(new { status = "ok", at = DateTimeOffset.UtcNow }));

app.Run();

public partial class Program;
