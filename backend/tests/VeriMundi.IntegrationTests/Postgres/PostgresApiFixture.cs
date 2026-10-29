using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using Testcontainers.PostgreSql;
using VeriMundi.Infrastructure.Ingestion;
using VeriMundi.Infrastructure.Persistence;

namespace VeriMundi.IntegrationTests.Postgres;

/// <summary>
/// Shared Postgres-backed API host for data-plane integration tests.
/// Prefer <c>VERIMUNDI_TEST_POSTGRES</c> (CI service / local docker-compose);
/// otherwise start an ephemeral Testcontainers Postgres when Docker is available.
/// Keeps <c>ASPNETCORE_ENVIRONMENT=Testing</c> so hosted ingestion loops stay off.
/// </summary>
public sealed class PostgresApiFixture : IAsyncLifetime
{
    private PostgreSqlContainer? _container;
    private string? _createdDatabase;

    public WebApplicationFactory<Program> Factory { get; private set; } = null!;

    public HttpClient Client { get; private set; } = null!;

    public async Task InitializeAsync()
    {
        var connectionString = await ResolveConnectionStringAsync();
        var fixturePath = ResolveFixturePath();

        Factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
            builder.UseSetting("ConnectionStrings:VeriMundi", connectionString);
            builder.ConfigureAppConfiguration((_, config) =>
            {
                // Insert at the front so these values win over appsettings.json.
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["ConnectionStrings:VeriMundi"] = connectionString,
                    // Pin fixture JSON so WAF content-root differences cannot skip ingest.
                    ["Ingestion:FixturePath"] = fixturePath,
                    // Fixture-only ingest; no hosted RSS/GDELT loops in Testing.
                    ["Ingestion:EnableRss"] = "false",
                    ["Ingestion:EnableGdelt"] = "false",
                    ["RateLimiting:Provider"] = "Memory",
                    ["RateLimiting:WritePerMinute"] = "1000",
                    ["RateLimiting:AskPerMinute"] = "1000",
                    ["RateLimiting:ReportPerMinute"] = "1000",
                });
            });
            // EF captures the connection string at registration — replace DbContext after
            // Program.cs DI so the isolated test database is used (not appsettings localhost).
            builder.ConfigureTestServices(services =>
            {
                RemoveDbContext<VeriMundiDbContext>(services);
                services.AddDbContext<VeriMundiDbContext>(options =>
                    options.UseNpgsql(connectionString));
            });
        });

        using (var scope = Factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<VeriMundiDbContext>();
            await SeedData.InitialiseAsync(db);
            var pipeline = scope.ServiceProvider.GetRequiredService<IngestionPipeline>();
            var result = await pipeline.RunAsync(trigger: "integration-test");
            if (result.ArticlesIngested <= 0 || result.ClustersCreated + result.ClustersAttached <= 0)
            {
                throw new InvalidOperationException(
                    "Postgres data-plane fixture seeded sources but fixture ingestion produced no stories. " +
                    $"FixturePath={fixturePath} Exists={File.Exists(fixturePath)} " +
                    $"Fetched={result.ArticlesFetched} Ingested={result.ArticlesIngested} " +
                    $"Duplicates={result.DuplicatesSkipped} " +
                    $"ClustersCreated={result.ClustersCreated} ClustersAttached={result.ClustersAttached} " +
                    $"Restricted={result.RestrictedSkipped} Unapproved={result.UnapprovedSkipped}.");
            }
        }

        Client = Factory.CreateClient();
    }

    private static void RemoveDbContext<TContext>(IServiceCollection services)
        where TContext : DbContext
    {
        var toRemove = services
            .Where(d =>
                d.ServiceType == typeof(TContext) ||
                d.ServiceType == typeof(DbContextOptions<TContext>) ||
                d.ServiceType == typeof(DbContextOptions) ||
                (d.ServiceType.IsGenericType &&
                 d.ServiceType.GetGenericTypeDefinition() == typeof(DbContextOptions<>) &&
                 d.ServiceType.GenericTypeArguments[0] == typeof(TContext)))
            .ToList();
        foreach (var descriptor in toRemove)
        {
            services.Remove(descriptor);
        }
    }

    public async Task DisposeAsync()
    {
        Client?.Dispose();
        if (Factory is not null)
        {
            await Factory.DisposeAsync();
        }

        if (_createdDatabase is not null)
        {
            try
            {
                await DropDatabaseAsync(_createdDatabase);
            }
            catch
            {
                // Best-effort cleanup for CI/shared Postgres.
            }
        }

        if (_container is not null)
        {
            await _container.DisposeAsync();
        }
    }

    private static string ResolveFixturePath()
    {
        // Prefer Api output next to the entry assembly (CopyToOutputDirectory).
        var apiDir = Path.GetDirectoryName(typeof(Program).Assembly.Location);
        if (!string.IsNullOrEmpty(apiDir))
        {
            var fromApiOutput = Path.Combine(apiDir, "Fixtures", "seed_articles.json");
            if (File.Exists(fromApiOutput))
            {
                return fromApiOutput;
            }
        }

        var fromTestOutput = Path.Combine(AppContext.BaseDirectory, "Fixtures", "seed_articles.json");
        if (File.Exists(fromTestOutput))
        {
            return fromTestOutput;
        }

        // Source tree fallback when running from an unusual output layout.
        var fromRepo = Path.GetFullPath(Path.Combine(
            AppContext.BaseDirectory,
            "..", "..", "..", "..", "..",
            "src", "VeriMundi.Api", "Fixtures", "seed_articles.json"));
        if (File.Exists(fromRepo))
        {
            return fromRepo;
        }

        throw new FileNotFoundException(
            "Could not locate Fixtures/seed_articles.json for Postgres data-plane tests.");
    }

    private async Task<string> ResolveConnectionStringAsync()
    {
        var external = Environment.GetEnvironmentVariable("VERIMUNDI_TEST_POSTGRES");
        if (string.IsNullOrWhiteSpace(external))
        {
            external = Environment.GetEnvironmentVariable("ConnectionStrings__VeriMundi");
        }

        if (!string.IsNullOrWhiteSpace(external))
        {
            // Isolate parallel CI/local runs on a shared server.
            _createdDatabase = $"verimundi_it_{Guid.NewGuid():N}";
            await CreateDatabaseAsync(external, _createdDatabase);
            return WithDatabase(external, _createdDatabase);
        }

        try
        {
            _container = new PostgreSqlBuilder()
                .WithImage("postgres:16-alpine")
                .WithDatabase("verimundi")
                .WithUsername("verimundi")
                .WithPassword("verimundi")
                .Build();
            await _container.StartAsync();
            return _container.GetConnectionString();
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                "Postgres data-plane tests require either VERIMUNDI_TEST_POSTGRES " +
                "(CI Postgres service / docker-compose) or a working Docker daemon for Testcontainers. " +
                "See backend/README.md.",
                ex);
        }
    }

    private static async Task CreateDatabaseAsync(string baseConnectionString, string databaseName)
    {
        var admin = WithDatabase(baseConnectionString, "postgres");
        await using var conn = new NpgsqlConnection(admin);
        await conn.OpenAsync();
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = $"CREATE DATABASE \"{databaseName}\"";
        await cmd.ExecuteNonQueryAsync();
    }

    private async Task DropDatabaseAsync(string databaseName)
    {
        var external = Environment.GetEnvironmentVariable("VERIMUNDI_TEST_POSTGRES")
            ?? Environment.GetEnvironmentVariable("ConnectionStrings__VeriMundi");
        if (string.IsNullOrWhiteSpace(external))
        {
            return;
        }

        var admin = WithDatabase(external, "postgres");
        await using var conn = new NpgsqlConnection(admin);
        await conn.OpenAsync();
        await using (var terminate = conn.CreateCommand())
        {
            terminate.CommandText =
                "SELECT pg_terminate_backend(pid) FROM pg_stat_activity " +
                "WHERE datname = @db AND pid <> pg_backend_pid()";
            terminate.Parameters.AddWithValue("db", databaseName);
            await terminate.ExecuteNonQueryAsync();
        }

        await using var drop = conn.CreateCommand();
        drop.CommandText = $"DROP DATABASE IF EXISTS \"{databaseName}\"";
        await drop.ExecuteNonQueryAsync();
    }

    private static string WithDatabase(string connectionString, string database)
    {
        var builder = new NpgsqlConnectionStringBuilder(connectionString)
        {
            Database = database
        };
        return builder.ConnectionString;
    }
}

[CollectionDefinition(Name)]
public sealed class PostgresDataPlaneCollection : ICollectionFixture<PostgresApiFixture>
{
    public const string Name = "PostgresDataPlane";
}
