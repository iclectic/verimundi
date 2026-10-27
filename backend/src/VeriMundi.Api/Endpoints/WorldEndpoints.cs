using Microsoft.EntityFrameworkCore;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Mapping;
using VeriMundi.Application.Scoring;
using VeriMundi.Domain;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Api.Endpoints;

public static class WorldEndpoints
{
    public static RouteGroupBuilder MapWorldEndpoints(this RouteGroupBuilder api)
    {
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

        api.MapGet("/countries/{countryCode}/stories", async (
            string countryCode,
            VeriMundiDbContext db,
            int page = 1,
            int pageSize = 20) =>
        {
            (page, pageSize) = EndpointHelpers.NormalizePaging(page, pageSize);
            var query = db.Stories.AsNoTracking()
                .Include(s => s.ArticleLinks).ThenInclude(l => l.Article!).ThenInclude(a => a.Source)
                .Include(s => s.Claims).ThenInclude(c => c.Evidence)
                .Where(s => s.Status == StoryStatus.Active && s.PrimaryCountryCode == countryCode.ToUpperInvariant())
                .OrderByDescending(s => s.LastUpdatedAt);
            var total = await query.CountAsync();
            var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
            return Results.Ok(new PagedResponse<StoryDto>(items.Select(s => StoryMapper.ToDto(s)).ToList(), page, pageSize, total));
        });

        return api;
    }
}
