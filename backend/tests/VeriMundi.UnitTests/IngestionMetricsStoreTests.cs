using FluentAssertions;
using VeriMundi.Infrastructure.Ingestion;

namespace VeriMundi.UnitTests;

public class IngestionMetricsStoreTests
{
    [Fact]
    public void RecordSuccess_updates_totals_and_last_run()
    {
        var store = new IngestionMetricsStore();
        var started = DateTimeOffset.Parse("2026-10-26T12:00:00Z");
        var completed = started.AddMilliseconds(42);
        var result = new IngestionResult(
            ArticlesIngested: 3,
            ClusterOperations: 3,
            ClustersCreated: 2,
            ClustersAttached: 1,
            DuplicatesSkipped: 4,
            UnapprovedSkipped: 1,
            RestrictedSkipped: 0,
            ProviderFailures: 1,
            ProvidersAttempted: 2,
            ArticlesFetched: 10,
            ProposedSourcesCreated: 1,
            SynthesesRun: 2,
            DurationMs: 42,
            StartedAt: started,
            CompletedAt: completed,
            Trigger: "admin");

        store.RecordSuccess(result);
        store.RecordSuccess(result with { ArticlesIngested = 1, ProviderFailures = 0, Trigger = "hosted" });

        var snap = store.Snapshot();
        snap.CyclesCompleted.Should().Be(2);
        snap.CyclesFailed.Should().Be(0);
        snap.ArticlesIngestedTotal.Should().Be(4);
        snap.ProviderFailuresTotal.Should().Be(1);
        snap.LastRun.Should().NotBeNull();
        snap.LastRun!.Trigger.Should().Be("hosted");
        snap.LastRun.ArticlesIngested.Should().Be(1);
    }

    [Fact]
    public void RecordFailure_increments_failed_cycles()
    {
        var store = new IngestionMetricsStore();
        store.RecordFailure("hosted", new InvalidOperationException("db down"));

        var snap = store.Snapshot();
        snap.CyclesFailed.Should().Be(1);
        snap.CyclesCompleted.Should().Be(0);
        snap.LastRun!.Trigger.Should().Contain("hosted:failed");
    }
}
