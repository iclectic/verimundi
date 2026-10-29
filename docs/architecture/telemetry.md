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

## Quota dashboards & alerts (ops playbook)

Meters above are the data source. Hosted Grafana/Alertmanager wiring stays **EXTERNAL**; use these PromQL sketches once `Telemetry:EnablePrometheus=true` on Staging/Production and a scraper is attached.

### Suggested panels

| Panel | PromQL (sketch) | Notes |
| --- | --- | --- |
| Rate-limit 429s | `sum by (kind) (rate(verimundi_api_rate_limited_total[5m]))` | Tag `kind` = `write` \| `ask` \| `report` |
| Ask volume | `rate(verimundi_api_ask_requests_total[5m])` | Watch spikes vs baseline |
| Ask / search latency | `histogram_quantile(0.95, sum by (le, route_group) (rate(verimundi_api_http_duration_ms_bucket{route_group=~"ask\|search"}[5m])))` | Correlate with ingest cycles |
| Ingestion failures | `rate(verimundi_ingestion_cycles_failed_total[15m])` | Non-zero warrants ops check |
| Ingestion duration | `histogram_quantile(0.95, sum by (le, trigger) (rate(verimundi_ingestion_duration_ms_bucket[15m])))` | Contends with API when co-located |

Exact counter/histogram suffix names follow the OpenTelemetry Prometheus exporter (`_total`, `_bucket`). Confirm against a live `/metrics` scrape after enabling Prometheus.

### Alert sketches (not shipped as code)

| Alert | Condition (sketch) | Action |
| --- | --- | --- |
| Ask/report abuse | `rate(verimundi_api_rate_limited_total{kind=~"ask\|report"}[5m])` sustained above staging baseline | Check edge/WAF; tighten `RateLimiting:*` if needed |
| Write flood | Same for `kind="write"` | Same |
| Ingest failing | `increase(verimundi_ingestion_cycles_failed_total[30m]) > 0` | Check provider HTTP / DB; admin metrics |
| Co-located latency | Ask/search p95 rises while `verimundi_ingestion_duration_ms` is high | Consider `Ingestion:EnableHostedWorker=false` + separate worker (see `backend_decision.md`) |

Staging enablement checklist: set `Telemetry__EnablePrometheus=true`, scrape `/metrics` from the API service only (not public internet), and file dashboard JSON in the ops repo when a Grafana org exists. In-app Redis rate limits remain defence-in-depth; edge alerts on HTTP 429 remain recommended (`docs/editorial/abuse_prevention.md`).

## Related

- Testing matrix: `docs/architecture/testing.md`
- Abuse / rate limits: `docs/editorial/abuse_prevention.md`
- Deploy topology / blast radius: `docs/architecture/backend_decision.md`
