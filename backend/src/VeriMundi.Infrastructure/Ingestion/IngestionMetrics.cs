namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// Counters for a single ingestion cycle (hosted or admin-triggered).
/// </summary>
public sealed record IngestionResult(
    int ArticlesIngested,
    int ClusterOperations,
    int ClustersCreated,
    int ClustersAttached,
    int DuplicatesSkipped,
    int UnapprovedSkipped,
    int RestrictedSkipped,
    int ProviderFailures,
    int ProvidersAttempted,
    int ArticlesFetched,
    int ProposedSourcesCreated,
    int SynthesesRun,
    int DurationMs,
    DateTimeOffset StartedAt,
    DateTimeOffset CompletedAt,
    string Trigger)
{
    public static IngestionResult Empty(string trigger, DateTimeOffset startedAt) => new(
        ArticlesIngested: 0,
        ClusterOperations: 0,
        ClustersCreated: 0,
        ClustersAttached: 0,
        DuplicatesSkipped: 0,
        UnapprovedSkipped: 0,
        RestrictedSkipped: 0,
        ProviderFailures: 0,
        ProvidersAttempted: 0,
        ArticlesFetched: 0,
        ProposedSourcesCreated: 0,
        SynthesesRun: 0,
        DurationMs: 0,
        StartedAt: startedAt,
        CompletedAt: startedAt,
        Trigger: trigger);
}

/// <summary>
/// Process-local totals + last run for ops visibility (not a substitute for Prometheus).
/// </summary>
public sealed class IngestionMetricsStore
{
    private readonly object _gate = new();
    private IngestionResult? _lastRun;
    private long _cyclesCompleted;
    private long _cyclesFailed;
    private long _articlesIngestedTotal;
    private long _providerFailuresTotal;

    public void RecordSuccess(IngestionResult result)
    {
        lock (_gate)
        {
            _lastRun = result;
            _cyclesCompleted++;
            _articlesIngestedTotal += result.ArticlesIngested;
            _providerFailuresTotal += result.ProviderFailures;
        }

        IngestionTelemetry.RecordSuccess(result);
    }

    public void RecordFailure(string trigger, Exception ex)
    {
        lock (_gate)
        {
            _cyclesFailed++;
            _lastRun = new IngestionResult(
                ArticlesIngested: 0,
                ClusterOperations: 0,
                ClustersCreated: 0,
                ClustersAttached: 0,
                DuplicatesSkipped: 0,
                UnapprovedSkipped: 0,
                RestrictedSkipped: 0,
                ProviderFailures: 0,
                ProvidersAttempted: 0,
                ArticlesFetched: 0,
                ProposedSourcesCreated: 0,
                SynthesesRun: 0,
                DurationMs: 0,
                StartedAt: DateTimeOffset.UtcNow,
                CompletedAt: DateTimeOffset.UtcNow,
                Trigger: $"{trigger}:failed:{ex.GetType().Name}");
        }

        IngestionTelemetry.RecordFailure(trigger);
    }

    public IngestionMetricsSnapshot Snapshot()
    {
        lock (_gate)
        {
            return new IngestionMetricsSnapshot(
                CyclesCompleted: _cyclesCompleted,
                CyclesFailed: _cyclesFailed,
                ArticlesIngestedTotal: _articlesIngestedTotal,
                ProviderFailuresTotal: _providerFailuresTotal,
                LastRun: _lastRun);
        }
    }
}

public sealed record IngestionMetricsSnapshot(
    long CyclesCompleted,
    long CyclesFailed,
    long ArticlesIngestedTotal,
    long ProviderFailuresTotal,
    IngestionResult? LastRun);
