# VeriMundi telemetry

## Default

Telemetry export is **off**. The API still:

- Writes structured HTTP log lines (`Method`, `Path`, `StatusCode`, `ElapsedMs`, `TraceId`, `RouteGroup`)
- Updates process-local `IngestionMetricsStore` (`GET /v1/admin/ingestion/metrics`, ops-gated)
- Increments in-process meters (visible on scrape only when Prometheus is enabled)

## Meters

### Ingestion — `VeriMundi.Ingestion`

| Instrument | Type | Meaning |
| --- | --- | --- |
| `verimundi_ingestion_cycles_completed` | counter | Successful cycles |
| `verimundi_ingestion_cycles_failed` | counter | Failed cycles |
| `verimundi_ingestion_articles_ingested` | counter | Persisted articles |
| `verimundi_ingestion_articles_fetched` | counter | Provider batch sizes |
| `verimundi_ingestion_duplicates_skipped` | counter | Canonical hash hits |
| `verimundi_ingestion_unapproved_skipped` | counter | Non-approved non-fixture |
| `verimundi_ingestion_restricted_skipped` | counter | Rejected/restricted |
| `verimundi_ingestion_clusters_created` | counter | New story clusters |
| `verimundi_ingestion_clusters_attached` | counter | Links to existing clusters |
| `verimundi_ingestion_syntheses_run` | counter | AI/heuristic synthesises |
| `verimundi_ingestion_provider_failures` | counter | Provider exceptions |
| `verimundi_ingestion_proposed_sources_created` | counter | Auto-proposed domains |
| `verimundi_ingestion_duration_ms` | histogram | Cycle duration |

Tag: `trigger` = `startup` \| `hosted` \| `admin` \| …

### API — `VeriMundi.Api`

| Instrument | Type | Meaning |
| --- | --- | --- |
| `verimundi_api_http_requests` | counter | All HTTP requests |
| `verimundi_api_http_duration_ms` | histogram | Request duration |
| `verimundi_api_ask_requests` | counter | Ask answers (incl. insufficient evidence) |
| `verimundi_api_reports_accepted` | counter | Accepted problem reports |
| `verimundi_api_rate_limited` | counter | 429 from write/ask/report limiters |

HTTP tags: `method`, `status_class` (`2xx`…), `route_group` (`ask` \| `reports` \| `search` \| `stories` \| `admin` \| `api` \| `ops` \| …).  
Ask tag: `insufficient_evidence`. Report tag: `reason` (allowlisted). Rate-limit tag: `kind` = `write` \| `ask` \| `report`.

## Prometheus scrape

```bash
export Telemetry__EnablePrometheus=true
# Telemetry__PrometheusPath=/metrics   # default
```

Then scrape `GET /metrics`. Config section: `Telemetry` in `appsettings.json`.

## OTLP

An OTLP NuGet exporter is **not** referenced in this repo currently (moderate advisory on recent `OpenTelemetry.Exporter.OpenTelemetryProtocol` builds). Prefer:

1. Prometheus scrape → Grafana Agent / OTEL Collector prometheus receiver, or
2. Adding a patched OTLP package later behind `Telemetry:EnableOtlp` once the advisory is cleared.

## Related

- Testing matrix: `docs/architecture/testing.md`
- Abuse / rate limits: `docs/editorial/abuse_prevention.md`
