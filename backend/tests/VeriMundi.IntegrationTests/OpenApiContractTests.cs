using System.Text.Json.Nodes;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using VeriMundi.IntegrationTests.OpenApi;

namespace VeriMundi.IntegrationTests;

/// <summary>
/// Locks the client↔API OpenAPI surface for stories page, search, Ask, and app config.
/// Unintended diffs fail CI; intentional breaks acknowledge by regenerating
/// <c>backend/contracts/openapi.v1.json</c> via <c>UPDATE_OPENAPI_SNAPSHOT=1</c>.
/// </summary>
public class OpenApiContractTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public OpenApiContractTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Testing");
        });
    }

    [Fact]
    public void Snapshot_matches_committed_openapi()
    {
        var actual = OpenApiSnapshot.ExportNormalizedDocument(_factory);
        var path = OpenApiSnapshot.CommittedSnapshotPath;

        if (string.Equals(
                Environment.GetEnvironmentVariable("UPDATE_OPENAPI_SNAPSHOT"),
                "1",
                StringComparison.Ordinal))
        {
            Directory.CreateDirectory(Path.GetDirectoryName(path)!);
            File.WriteAllText(path, actual);
            return;
        }

        File.Exists(path).Should().BeTrue(
            "committed OpenAPI snapshot must exist at {0}. Run backend/scripts/export-openapi.sh",
            path);
        var expected = OpenApiSnapshot.Normalize(File.ReadAllText(path));
        actual.Should().Be(
            expected,
            "OpenAPI drifted from backend/contracts/openapi.v1.json. " +
            "If the change is intentional, regenerate with: UPDATE_OPENAPI_SNAPSHOT=1 " +
            "dotnet test --filter FullyQualifiedName~OpenApiContractTests.Snapshot_matches_committed_openapi " +
            "(or backend/scripts/export-openapi.sh), then commit the updated snapshot.");
    }

    [Fact]
    public void Critical_paths_and_schemas_are_present()
    {
        var json = OpenApiSnapshot.ExportNormalizedDocument(_factory);
        var root = OpenApiSnapshot.ParseObject(json);
        var paths = root["paths"] as JsonObject;
        paths.Should().NotBeNull();

        paths!.ContainsKey("/v1/stories").Should().BeTrue();
        paths.ContainsKey("/v1/search").Should().BeTrue();
        paths.ContainsKey("/v1/stories/{storyId}/questions").Should().BeTrue();
        paths.ContainsKey("/v1/app/config").Should().BeTrue();

        var schemas = root["components"]?["schemas"] as JsonObject;
        schemas.Should().NotBeNull("Swagger must emit component schemas for DTOs");

        AssertSchemaHasProperties(schemas!, "PagedResponse_StoryDto", "items", "page", "pageSize", "total");
        AssertSchemaHasProperties(
            schemas!,
            "StoryDto",
            "id",
            "headline",
            "shortSummary",
            "sourceArticles",
            "confirmedFacts",
            "disputedClaims",
            "uncertainties",
            "confidenceScore",
            "isDemoContent");
        AssertSchemaHasProperties(
            schemas!,
            "QuestionResponse",
            "answer",
            "insufficientEvidence",
            "confidenceScore",
            "sourceIds",
            "uncertainty",
            "generatedAt");
        AssertSchemaHasProperties(
            schemas!,
            "QuestionRequest",
            "question");
        AssertSchemaHasProperties(
            schemas!,
            "AppConfigDto",
            "environment",
            "maintenanceMode",
            "minimumAppVersion",
            "ingestion",
            "ai",
            "disclaimer");
        AssertSchemaHasProperties(schemas!, "AppConfigIngestionDto", "enableRss", "enableGdelt");
        AssertSchemaHasProperties(schemas!, "AppConfigAiDto", "provider");
    }

    [Fact]
    public void Ask_and_config_operations_declare_success_schemas()
    {
        var json = OpenApiSnapshot.ExportNormalizedDocument(_factory);
        var root = OpenApiSnapshot.ParseObject(json);
        var paths = root["paths"]!.AsObject();

        var storiesGet = paths["/v1/stories"]!["get"]!;
        SchemaRef(storiesGet, "200").Should().Contain("PagedResponse_StoryDto");

        var searchGet = paths["/v1/search"]!["get"]!;
        SchemaRef(searchGet, "200").Should().Contain("PagedResponse_StoryDto");

        var askPost = paths["/v1/stories/{storyId}/questions"]!["post"]!;
        SchemaRef(askPost, "200").Should().Contain("QuestionResponse");

        var configGet = paths["/v1/app/config"]!["get"]!;
        SchemaRef(configGet, "200").Should().Contain("AppConfigDto");
    }

    private static void AssertSchemaHasProperties(
        JsonObject schemas,
        string schemaName,
        params string[] propertyNames)
    {
        schemas.ContainsKey(schemaName).Should().BeTrue("missing schema {0}", schemaName);
        var props = schemas[schemaName]?["properties"] as JsonObject;
        props.Should().NotBeNull("schema {0} should declare properties", schemaName);
        foreach (var name in propertyNames)
        {
            props!.ContainsKey(name).Should().BeTrue("schema {0} missing property {1}", schemaName, name);
        }
    }

    private static string SchemaRef(JsonNode operation, string statusCode)
    {
        var content = operation["responses"]?[statusCode]?["content"]?["application/json"]?["schema"];
        content.Should().NotBeNull("operation missing {0} application/json schema", statusCode);
        return content!.ToJsonString();
    }
}
