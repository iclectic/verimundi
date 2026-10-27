namespace VeriMundi.Api.Endpoints;

internal static class EndpointHelpers
{
    public static (int Page, int PageSize) NormalizePaging(int page, int pageSize)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 100);
        return (page, pageSize);
    }
}
