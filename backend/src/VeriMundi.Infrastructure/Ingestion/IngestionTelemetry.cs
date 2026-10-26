using System.Diagnostics.Metrics;

namespace VeriMundi.Infrastructure.Ingestion;

/// <summary>
/// OpenTelemetry-compatible instruments for ingestion (System.Diagnostics.Metrics).
/// Exported when the API enables the Prometheus scrape endpoint.
/// </summary>
public static class IngestionTelemetry
{
    public const string MeterName = "VeriMundi.Ingestion";

    private static readonly Meter Meter = new(MeterName, "1.0.0");

    public static readonly Counter<long> CyclesCompleted =
        Meter.CreateCounter<long>("verimundi_ingestion_cycles_completed", description: "Successful ingestion cycles");

    public static readonly Counter<long> CyclesFailed =
        Meter.CreateCounter<long>("verimundi_ingestion_cycles_failed", description: "Failed ingestion cycles");

    public static readonly Counter<long> ArticlesIngested =
        Meter.CreateCounter<long>("verimundi_ingestion_articles_ingested", description: "Articles persisted");

    public static readonly Counter<long> ArticlesFetched =
        Meter.CreateCounter<long>("verimundi_ingestion_articles_fetched", description: "Articles returned by providers");

    public static readonly Counter<long> DuplicatesSkipped =
        Meter.CreateCounter<long>("verimundi_ingestion_duplicates_skipped");

    public static readonly Counter<long> UnapprovedSkipped =
        Meter.CreateCounter<long>("verimundi_ingestion_unapproved_skipped");

    public static readonly Counter<long> RestrictedSkipped =
        Meter.CreateCounter<long>("verimundi_ingestion_restricted_skipped");

    public static readonly Counter<long> ClustersCreated =
        Meter.CreateCounter<long>("verimundi_ingestion_clusters_created");

    public static readonly Counter<long> ClustersAttached =
        Meter.CreateCounter<long>("verimundi_ingestion_clusters_attached");

    public static readonly Counter<long> SynthesesRun =
        Meter.CreateCounter<long>("verimundi_ingestion_syntheses_run");

    public static readonly Counter<long> ProviderFailures =
        Meter.CreateCounter<long>("verimundi_ingestion_provider_failures");

    public static readonly Counter<long> ProposedSourcesCreated =
        Meter.CreateCounter<long>("verimundi_ingestion_proposed_sources_created");

    public static readonly Histogram<double> DurationMilliseconds =
        Meter.CreateHistogram<double>(
            "verimundi_ingestion_duration_ms",
            unit: "ms",
            description: "Ingestion cycle duration");

    public static void RecordSuccess(IngestionResult result)
    {
        var tags = new KeyValuePair<string, object?>("trigger", result.Trigger);
        CyclesCompleted.Add(1, tags);
        ArticlesIngested.Add(result.ArticlesIngested, tags);
        ArticlesFetched.Add(result.ArticlesFetched, tags);
        DuplicatesSkipped.Add(result.DuplicatesSkipped, tags);
        UnapprovedSkipped.Add(result.UnapprovedSkipped, tags);
        RestrictedSkipped.Add(result.RestrictedSkipped, tags);
        ClustersCreated.Add(result.ClustersCreated, tags);
        ClustersAttached.Add(result.ClustersAttached, tags);
        SynthesesRun.Add(result.SynthesesRun, tags);
        ProviderFailures.Add(result.ProviderFailures, tags);
        ProposedSourcesCreated.Add(result.ProposedSourcesCreated, tags);
        DurationMilliseconds.Record(result.DurationMs, tags);
    }

    public static void RecordFailure(string trigger)
    {
        CyclesFailed.Add(1, new KeyValuePair<string, object?>("trigger", trigger));
    }
}
