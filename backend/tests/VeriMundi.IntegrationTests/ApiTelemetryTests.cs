using System.Diagnostics.Metrics;
using FluentAssertions;
using VeriMundi.Api.Telemetry;

namespace VeriMundi.IntegrationTests;

public class ApiTelemetryTests
{
    [Theory]
    [InlineData("/v1/stories/abc/questions", "ask")]
    [InlineData("/v1/stories/abc/reports", "reports")]
    [InlineData("/v1/search", "search")]
    [InlineData("/v1/stories", "stories")]
    [InlineData("/v1/admin/ingestion/run", "admin")]
    [InlineData("/v1/app/config", "api")]
    [InlineData("/health", "ops")]
    [InlineData("/metrics", "ops")]
    [InlineData("/favicon.ico", "other")]
    public void RouteGroup_classifies_paths(string path, string expected)
    {
        ApiTelemetry.RouteGroup(path).Should().Be(expected);
    }

    [Fact]
    public void RecordAsk_emits_counter_measurement()
    {
        long seen = 0;
        using var listener = new MeterListener();
        listener.InstrumentPublished = (instrument, meterListener) =>
        {
            if (instrument.Meter.Name == ApiTelemetry.MeterName &&
                instrument.Name == "verimundi_api_ask_requests")
            {
                meterListener.EnableMeasurementEvents(instrument);
            }
        };
        listener.SetMeasurementEventCallback<long>((_, measurement, _, _) =>
        {
            seen += measurement;
        });
        listener.Start();

        ApiTelemetry.RecordAsk(insufficientEvidence: true);
        seen.Should().BeGreaterThanOrEqualTo(1);
    }

    [Fact]
    public void RecordRateLimited_emits_counter_measurement()
    {
        long seen = 0;
        using var listener = new MeterListener();
        listener.InstrumentPublished = (instrument, meterListener) =>
        {
            if (instrument.Meter.Name == ApiTelemetry.MeterName &&
                instrument.Name == "verimundi_api_rate_limited")
            {
                meterListener.EnableMeasurementEvents(instrument);
            }
        };
        listener.SetMeasurementEventCallback<long>((_, measurement, _, _) =>
        {
            seen += measurement;
        });
        listener.Start();

        ApiTelemetry.RecordRateLimited("report");
        seen.Should().BeGreaterThanOrEqualTo(1);
    }
}
