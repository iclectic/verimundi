using Microsoft.Extensions.Logging;
using VeriMundi.Application.Abstractions;
using VeriMundi.Application.Ingestion;

namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// Scaffold for GDELT DOC 2.0 discovery metadata. Disabled by default.
/// Does not fetch or store article bodies. Enable only after terms review
/// (<c>Ingestion:EnableGdelt=true</c>) and source-registry approval.
/// </summary>
public sealed class GdeltDiscoveryProvider(ILogger<GdeltDiscoveryProvider> logger) : INewsProvider
{
    public string Name => "gdelt";

    public Task<IReadOnlyList<IngestedArticle>> FetchLatestAsync(
        IngestionRequest request,
        CancellationToken cancellationToken = default)
    {
        logger.LogInformation(
            "GDELT discovery provider is scaffolded but not performing network calls until approved. " +
            "See docs/sources/source_registry.md.");
        return Task.FromResult<IReadOnlyList<IngestedArticle>>(Array.Empty<IngestedArticle>());
    }
}
