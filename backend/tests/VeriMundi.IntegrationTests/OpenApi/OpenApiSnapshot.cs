using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Writers;
using Swashbuckle.AspNetCore.Swagger;
using VeriMundi.Api.OpenApi;

namespace VeriMundi.IntegrationTests.OpenApi;

internal static class OpenApiSnapshot
{
    private static readonly JsonSerializerOptions WriteOptions = new()
    {
        WriteIndented = true
    };

    /// <summary>
    /// Resolves <c>backend/contracts/openapi.v1.json</c> from the test output directory.
    /// </summary>
    public static string CommittedSnapshotPath
    {
        get
        {
            var dir = new DirectoryInfo(AppContext.BaseDirectory);
            while (dir is not null)
            {
                var candidate = Path.Combine(dir.FullName, "contracts", "openapi.v1.json");
                if (File.Exists(candidate) || Directory.Exists(Path.Combine(dir.FullName, "src", "VeriMundi.Api")))
                {
                    return candidate;
                }

                dir = dir.Parent;
            }

            throw new InvalidOperationException(
                "Could not locate backend/contracts relative to the test output directory.");
        }
    }

    public static string ExportNormalizedDocument(WebApplicationFactory<Program> factory)
    {
        _ = factory.CreateClient();
        var provider = factory.Services.GetRequiredService<ISwaggerProvider>();
        var document = provider.GetSwagger(OpenApiContractSetup.DocumentName);

        using var stringWriter = new StringWriter(new StringBuilder(capacity: 64 * 1024));
        var jsonWriter = new OpenApiJsonWriter(stringWriter);
        document.SerializeAsV3(jsonWriter);
        return Normalize(stringWriter.ToString());
    }

    public static string Normalize(string openApiJson)
    {
        var node = JsonNode.Parse(openApiJson)
            ?? throw new InvalidOperationException("OpenAPI document was empty.");
        // Drop volatile host metadata; paths + schemas are the contract.
        if (node is JsonObject root)
        {
            root.Remove("servers");
        }

        return node.ToJsonString(WriteOptions) + "\n";
    }

    public static JsonObject ParseObject(string openApiJson) =>
        JsonNode.Parse(openApiJson) as JsonObject
        ?? throw new InvalidOperationException("OpenAPI root must be an object.");
}
