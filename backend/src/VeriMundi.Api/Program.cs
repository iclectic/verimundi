using System.Text.Json;
using System.Text.Json.Serialization;
using VeriMundi.Api.Contracts;
using VeriMundi.Api.Endpoints;
using VeriMundi.Api.Middleware;
using VeriMundi.Api.Options;
using VeriMundi.Api.Telemetry;
using VeriMundi.Infrastructure;
using VeriMundi.Infrastructure.Ingestion;
using VeriMundi.Infrastructure.Persistence;
using VeriMundi.Workers;

var builder = WebApplication.CreateBuilder(args);
builder.AddVeriMundiTelemetry();

var fixturePath = Path.Combine(builder.Environment.ContentRootPath, "Fixtures", "seed_articles.json");
builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
{
    ["Ingestion:FixturePath"] = fixturePath
});

builder.Services.Configure<AppOptions>(builder.Configuration.GetSection(AppOptions.SectionName));
builder.Services.Configure<OpsAuthOptions>(builder.Configuration.GetSection(OpsAuthOptions.SectionName));
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
app.MapVeriMundiTelemetry();

app.UseCors();
app.UseMiddleware<SimpleRateLimitMiddleware>();
app.UseMiddleware<AskRateLimitMiddleware>();
app.UseMiddleware<ReportRateLimitMiddleware>();
app.Use(async (context, next) =>
{
    var started = DateTimeOffset.UtcNow;
    await next();
    var elapsedMs = (DateTimeOffset.UtcNow - started).TotalMilliseconds;
    var path = context.Request.Path.Value;
    var routeGroup = ApiTelemetry.RouteGroup(path);
    ApiTelemetry.RecordHttp(
        context.Request.Method,
        context.Response.StatusCode,
        routeGroup,
        elapsedMs);
    app.Logger.LogInformation(
        "HTTP {Method} {Path} => {StatusCode} in {ElapsedMs}ms TraceId={TraceId} RouteGroup={RouteGroup}",
        context.Request.Method,
        path,
        context.Response.StatusCode,
        elapsedMs,
        context.TraceIdentifier,
        routeGroup);
});

// Maintenance mode blocks product routes; health/ready/config/admin stay available
// (admin still requires the ops token gate on the endpoint itself).
app.Use(async (context, next) =>
{
    var path = context.Request.Path.Value ?? string.Empty;
    var isOpsProbe =
        path.Equals("/health", StringComparison.OrdinalIgnoreCase) ||
        path.Equals("/ready", StringComparison.OrdinalIgnoreCase) ||
        path.Equals("/v1/app/config", StringComparison.OrdinalIgnoreCase) ||
        path.StartsWith("/v1/admin", StringComparison.OrdinalIgnoreCase) ||
        path.Equals("/metrics", StringComparison.OrdinalIgnoreCase) ||
        path.StartsWith("/swagger", StringComparison.OrdinalIgnoreCase);

    if (!isOpsProbe)
    {
        var options = context.RequestServices.GetRequiredService<Microsoft.Extensions.Options.IOptions<AppOptions>>().Value;
        if (options.MaintenanceMode)
        {
            context.Response.StatusCode = StatusCodes.Status503ServiceUnavailable;
            context.Response.Headers.RetryAfter = "120";
            await context.Response.WriteAsJsonAsync(new ApiError(
                "maintenance",
                options.MaintenanceMessage ?? "Maintenance mode is enabled."));
            return;
        }
    }

    await next();
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
    await pipeline.RunAsync(trigger: "startup");
}

app.MapVeriMundiEndpoints();

app.Run();

public partial class Program;
