# VeriMundi engineering evidence (portfolio)

Honest changelog from mock MVP → production-oriented vertical slice (Phases 0–15 scaffolding), including post–PR #1 continue work on the live-path / ops-auth stacks.

## Product claim

VeriMundi broadens regional and source visibility. Selection, classification, and AI-assisted summaries remain imperfect and should be read alongside original reporting.

## What shipped in this completion arc

| Layer | Evidence |
| --- | --- |
| Flutter MVP preserved | Riverpod, GoRouter, Drift, Freezed, Material 3 feeds |
| Backend modular monolith | `backend/` ASP.NET Core 8 + PostgreSQL + `/v1` OpenAPI |
| Ingestion | Approved fixture sources; RSS/GDELT gated; registry docs with proposed rows |
| Clustering / scoring | URL/hash dedupe, independent counts, World Pulse regional balance |
| AI | Backend `IAiSynthesisService` heuristic path (no client secrets) |
| Flutter remote | `RemoteNewsRepository`, `APP_ENV`, typed `RemoteApiException`, retries, maintenance/min-version banners |
| Live-path ops | `/health`, `/ready`, `/v1/app/config`, docker-compose, staging smoke runbook |
| Map | Severity legend + icons, searchable/sortable country list (no GeoJSON yet) |
| Discovery | Debounced search, filters, chips, filter-aware empty states, paging UI |
| Offline | Feed metadata cache with fresh/stale/expired labels |
| Safety | Reports endpoint, rate-limit JSON, privacy/Data Safety drafts |
| Admin | Ops token gate on ingestion run/metrics; fail closed outside Dev/Testing when unset |
| Observability | Structured ingestion counters; process metrics API; optional Prometheus `/metrics` |
| CI | Flutter workflow + backend workflow |

## Screenshots / demos

Screenshots and device recordings should be captured on a machine with Android/iOS tooling. This environment cannot produce APK demos (see `docs/release/android_sdk_blocker.md`).

Suggested capture list:

1. World map + country list alternative (search/sort)  
2. Underreported feed with reason copy  
3. Story detail (facts, timeline, Ask, report)  
4. Saved snapshot age notice  
5. Settings data-mode + remote readiness  
6. Empty states (no clusters vs filters)  
7. Maintenance / typed error banners (remote)

## Methodology / ops docs

- `docs/methodology/world_pulse_ranking.md`
- `docs/methodology/underreported_methodology.md`
- `docs/sources/source_registry.md`
- `docs/architecture/backend_decision.md`
- `docs/architecture/map_geojson.md`
- `docs/architecture/telemetry.md`
- `docs/release/staging_flutter_api_smoke.md`

## Explicit non-claims

- Not yet a rights-cleared commercial news product (proposed sources stay disabled)  
- Not yet production GenAI (heuristic synthesis default)  
- Notifications not specified (truncated brief §26)  
- Android production bundle not verified in this environment  
- Choropleth GeoJSON not licensed/vendored  
- Staging host URL and ops secrets are operator-supplied (not in git)  
