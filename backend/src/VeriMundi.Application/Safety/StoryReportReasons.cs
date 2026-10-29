namespace VeriMundi.Application.Safety;

/// <summary>
/// Canonical user-report reasons. Must stay aligned with the Flutter report dialog.
/// Free-form reasons are rejected to reduce abuse and noisy moderation queues.
/// </summary>
public static class StoryReportReasons
{
    public const int MaxReasonLength = 120;
    public const int MaxDetailsLength = 500;

    public static readonly IReadOnlyList<string> Allowed =
    [
        "Incorrect summary",
        "Unsupported claim",
        "Outdated information",
        "Misleading classification",
        "Broken source",
        "Other",
    ];

    private static readonly HashSet<string> AllowedSet = new(Allowed, StringComparer.Ordinal);

    public static bool TryNormalize(string? reason, out string normalized)
    {
        normalized = (reason ?? string.Empty).Trim();
        return normalized.Length is > 0 and <= MaxReasonLength && AllowedSet.Contains(normalized);
    }

    public static bool IsDetailsValid(string? details) =>
        details is null || details.Length <= MaxDetailsLength;
}
