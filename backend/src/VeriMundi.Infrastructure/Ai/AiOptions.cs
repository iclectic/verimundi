namespace VeriMundi.Infrastructure.Ai;

/// <summary>
/// Backend-only GenAI settings. Secrets must come from environment / secret store —
/// never from the Flutter client or committed appsettings values.
/// </summary>
public sealed class AiOptions
{
    public const string SectionName = "Ai";

    /// <summary>Empty → heuristic provider. Non-empty → OpenAI-compatible chat completions.</summary>
    public string ApiKey { get; set; } = string.Empty;

    /// <summary>OpenAI-compatible base URL ending before <c>/chat/completions</c>.</summary>
    public string BaseUrl { get; set; } = "https://api.openai.com/v1";

    public string Model { get; set; } = "gpt-4o-mini";

    public int MaxOutputTokens { get; set; } = 1200;

    public double Temperature { get; set; } = 0.2;

    /// <summary>HTTP timeout for provider calls.</summary>
    public int TimeoutSeconds { get; set; } = 45;

    /// <summary>
    /// Legacy Ask limit. Prefer <c>RateLimiting:AskPerMinute</c>; bridged when that key is unset.
    /// </summary>
    public int AskPerMinutePerIp { get; set; } = 10;

    public bool IsConfigured => !string.IsNullOrWhiteSpace(ApiKey);

    public string EffectiveProvider => IsConfigured ? "openaiCompatible" : "heuristic";
}
