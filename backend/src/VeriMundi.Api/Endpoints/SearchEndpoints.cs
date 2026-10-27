using Microsoft.EntityFrameworkCore;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Mapping;
using VeriMundi.Domain;
using VeriMundi.Domain.Entities;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.Api.Endpoints;

public static class SearchEndpoints
{
    public static RouteGroupBuilder MapSearchEndpoints(this RouteGroupBuilder api)
    {
        api.MapGet("/search", async (
            VeriMundiDbContext db,
            string? q,
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
            // Discovery search: broader text match than /stories?query= (sources + whyItMatters).
            (page, pageSize) = EndpointHelpers.NormalizePaging(page, pageSize);
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
                    s.Region.Contains(queryText, StringComparison.OrdinalIgnoreCase) ||
                    s.PrimaryCountryCode.Contains(queryText, StringComparison.OrdinalIgnoreCase) ||
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

            var list = filtered.OrderByDescending(s => s.LastUpdatedAt).ToList();
            var total = list.Count;
            var items = list.Skip((page - 1) * pageSize).Take(pageSize).Select(s => StoryMapper.ToDto(s)).ToList();
            return Results.Ok(new PagedResponse<StoryDto>(items, page, pageSize, total));
        });

        return api;
    }
}
