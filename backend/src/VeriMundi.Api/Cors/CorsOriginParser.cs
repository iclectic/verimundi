namespace VeriMundi.Api.Cors;

internal static class CorsOriginParser
{
    /// <summary>
    /// Reads <c>Cors:AllowedOrigins</c> as an array or comma-separated string and normalises entries.
    /// </summary>
    public static string[] Parse(IConfigurationSection originsSection)
    {
        var fromChildren = originsSection.GetChildren()
            .Select(c => c.Value?.Trim())
            .Where(v => !string.IsNullOrEmpty(v))
            .Cast<string>()
            .ToArray();

        if (fromChildren.Length > 0)
        {
            return fromChildren;
        }

        var scalar = originsSection.Value?.Trim();
        if (string.IsNullOrEmpty(scalar))
        {
            return [];
        }

        return scalar
            .Split([',', ';'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Where(s => s.Length > 0)
            .ToArray();
    }
}
