using VeriMundi.Api.Cors;
using VeriMundi.Api.Options;

namespace VeriMundi.Api.Security;

/// <summary>
/// Fail-fast checks for Staging/Production so unsafe defaults cannot boot.
/// Prefer no dangerous overrides: Production cannot enable wildcard CORS.
/// </summary>
public static class ProductionStartupGuards
{
    public static bool IsHardenedEnvironment(IHostEnvironment environment) =>
        environment.IsProduction() ||
        environment.IsStaging() ||
        string.Equals(environment.EnvironmentName, "Staging", StringComparison.OrdinalIgnoreCase);

    /// <summary>
    /// Validates Production/Staging posture before the host serves traffic.
    /// No-op in Development/Testing.
    /// </summary>
    public static void Validate(IConfiguration configuration, IHostEnvironment environment)
    {
        if (!IsHardenedEnvironment(environment))
        {
            return;
        }

        EnsureOpsTokenConfigured(configuration);
        var origins = CorsOriginParser.Parse(
            configuration.GetSection(CorsOptions.SectionName).GetSection("AllowedOrigins"));
        EnsureCorsAllowlist(origins);
    }

    public static void EnsureOpsTokenConfigured(IConfiguration configuration)
    {
        var token = configuration.GetSection(OpsAuthOptions.SectionName)["AdminIngestionToken"]?.Trim();
        if (string.IsNullOrEmpty(token))
        {
            throw new InvalidOperationException(
                "Ops:AdminIngestionToken is required in Staging/Production. " +
                "Set Ops__AdminIngestionToken before starting the API.");
        }
    }

    public static void EnsureCorsAllowlist(IReadOnlyList<string> allowedOrigins)
    {
        if (allowedOrigins.Count == 0)
        {
            throw new InvalidOperationException(
                "Cors:AllowedOrigins must list at least one origin in Staging/Production. " +
                "Set Cors__AllowedOrigins__0=https://your-app.example (AllowAnyOrigin is not permitted).");
        }

        foreach (var origin in allowedOrigins)
        {
            if (string.IsNullOrWhiteSpace(origin) ||
                origin.Trim() == "*" ||
                origin.Contains('*', StringComparison.Ordinal))
            {
                throw new InvalidOperationException(
                    "Cors:AllowedOrigins must not contain wildcards in Staging/Production. " +
                    $"Refusing origin '{origin}'. Configure exact origins only.");
            }

            if (!Uri.TryCreate(origin.Trim(), UriKind.Absolute, out var uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                throw new InvalidOperationException(
                    $"Cors:AllowedOrigins entry '{origin}' is not a valid http(s) origin.");
            }
        }
    }
}
