namespace VeriMundi.Api.Options;

public sealed class AppOptions
{
    public const string SectionName = "App";

    /// <summary>When true, API returns 503 for feed/story reads (ops maintenance).</summary>
    public bool MaintenanceMode { get; set; }

    /// <summary>SemVer floor the Flutter client should enforce for remote mode.</summary>
    public string MinimumAppVersion { get; set; } = "1.0.0";

    public string? MaintenanceMessage { get; set; } =
        "VeriMundi is temporarily unavailable for maintenance. Please try again later.";
}
