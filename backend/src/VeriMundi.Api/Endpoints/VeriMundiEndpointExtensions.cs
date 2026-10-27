namespace VeriMundi.Api.Endpoints;

/// <summary>
/// Registers all product and ops HTTP endpoints. Keep <c>Program.cs</c> as pipeline + Map* only.
/// </summary>
public static class VeriMundiEndpointExtensions
{
    public static WebApplication MapVeriMundiEndpoints(this WebApplication app)
    {
        app.MapAppConfigHealthEndpoints();

        var api = app.MapGroup("/v1");
        api.MapWorldEndpoints();
        api.MapStoriesEndpoints();
        api.MapSearchEndpoints();
        api.MapAskEndpoints();
        api.MapReportEndpoints();
        api.MapAdminIngestionEndpoints();
        api.MapAppConfigEndpoints();

        return app;
    }
}
