namespace VeriMundi.Api.Options;

/// <summary>
/// Shared-secret gate for destructive/ops admin endpoints.
/// Configure via env <c>Ops__AdminIngestionToken</c> (never commit real values).
/// </summary>
public sealed class OpsAuthOptions
{
    public const string SectionName = "Ops";

    /// <summary>
    /// Expected value for <c>X-VeriMundi-Ops-Token</c> or <c>Authorization: Bearer</c>.
    /// Empty means: allow in Development/Testing only; reject elsewhere (fail closed).
    /// </summary>
    public string? AdminIngestionToken { get; set; }
}
