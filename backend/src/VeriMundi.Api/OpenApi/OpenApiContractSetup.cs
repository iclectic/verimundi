using Microsoft.OpenApi.Models;

namespace VeriMundi.Api.OpenApi;

/// <summary>
/// Swagger/OpenAPI registration for the client↔API contract surface.
/// The committed snapshot lives at <c>backend/contracts/openapi.v1.json</c>.
/// </summary>
public static class OpenApiContractSetup
{
    public const string DocumentName = "v1";

    public static IServiceCollection AddVeriMundiOpenApi(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc(DocumentName, new OpenApiInfo
            {
                Title = "VeriMundi API",
                Version = "v1",
                Description =
                    "REST contract for Flutter remote mode. Breaking changes require regenerating " +
                    "backend/contracts/openapi.v1.json (see backend/scripts/export-openapi.sh)."
            });
            options.CustomSchemaIds(type =>
            {
                if (!type.IsGenericType)
                {
                    return type.Name;
                }

                var name = type.Name.Split('`')[0];
                var args = string.Join("_", type.GetGenericArguments().Select(t => t.Name));
                return $"{name}_{args}";
            });
            options.SupportNonNullableReferenceTypes();
        });
        return services;
    }
}
