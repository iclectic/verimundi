namespace VeriMundi.Api.Options;

/// <summary>
/// Browser CORS policy. Development/Testing stay permissive;
/// Staging/Production require an explicit origin allowlist (no wildcards).
/// </summary>
public sealed class CorsOptions
{
    public const string SectionName = "Cors";

    /// <summary>
    /// Exact origins allowed for Staging/Production (e.g. <c>https://app.example.com</c>).
    /// Configure via env <c>Cors__AllowedOrigins__0</c>, <c>Cors__AllowedOrigins__1</c>, …
    /// Ignored in Development/Testing where <c>AllowAnyOrigin</c> remains for local DX.
    /// </summary>
    public string[] AllowedOrigins { get; set; } = [];
}
