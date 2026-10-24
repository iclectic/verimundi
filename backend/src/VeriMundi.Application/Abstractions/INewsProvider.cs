using VeriMundi.Application.Ingestion;

namespace VeriMundi.Application.Abstractions;

public interface INewsProvider
{
    string Name { get; }
    Task<IReadOnlyList<IngestedArticle>> FetchLatestAsync(
        IngestionRequest request,
        CancellationToken cancellationToken = default);
}

public sealed record IngestionRequest(
    DateTimeOffset? Since = null,
    int MaxItems = 50);
