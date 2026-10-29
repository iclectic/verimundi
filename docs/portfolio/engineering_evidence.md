# VeriMundi engineering evidence (portfolio)

Honest changelog from **mock MVP → live-news vertical slice** on dirty branch `cursor/verimundi-live-news-sources-b049` (Phases 0–15 scaffolding; live-path hardening through Phase 14 docs).  
**Commit/push of this stack:** not authorised in the continue brief — treat as working-tree evidence until a PR is opened.

## Product claim

VeriMundi broadens regional and source visibility. Selection, classification, and AI-assisted summaries remain imperfect and should be read alongside original reporting. Demo builds use fictional content; live builds talk to a VeriMundi API and must never silently fall back to mock news in production.

## Mock → live arc (phases)

| Phase | Status | Portfolio evidence |
| --- | --- | --- |
| 0–1 | Done | AGENTS/completion docs; ASP.NET Core 8 + Postgres + `/v1` OpenAPI modular monolith |
| **2–3** Live sources | Done (terms-reviewed) | Fixtures + **UN News** approved RSS; **GDELT** MetadataOnly; ReliefWeb/WHO **restricted** (no fake clearance); `docs/sources/*` |
| 4–5 | Done (v1) | URL/hash dedupe + clustering; Underreported + World Pulse rankers + methodology docs |
| **6** GenAI | Done (optional) | Heuristic default; OpenAI-compatible host path; grounded Ask; `ask_rate_limited`; `docs/ai_safety.md` |
| **7** Flutter remote | Done + polish | `RemoteNewsRepository`; production never silent-mock; typed errors; `/v1/app/config` + `ai.provider` |
| **8** Map | Done | Natural Earth **public-domain** 110m choropleth; hatch+icons (not colour alone); country panel; list a11y |
| **9** Discovery | Done (hardened) | Query → `/v1/search`; dismissible chips; server totals / pagination |
| **10** Offline | Done (hardened) | Drift envelope cache; expired served with offline “not live” labels; underreported/positive cache |
| **11** Privacy/safety | Hardened draft | Privacy + Data Safety live-path drafts; report allowlist; `report_rate_limited`; **legal review EXTERNAL** |
| **12** UI/a11y | Done (hardened) | Story detail completeness; `NewsLabels` British English; section/card/map semantics |
| **13** Tests/obs | Done (hardened) | Flutter+backend CI; TraceId logs; ingestion + **API** OTEL meters; Prometheus; `docs/architecture/testing.md` |
| **14** Android | Blocked externally | Signing/CI/Play dual-track docs; main manifest `INTERNET`; **no APK/AAB** without `ANDROID_HOME` |
| **15** Portfolio | This doc | Changelog + doc index; screenshots/SDK gaps called out below |

## What shipped (layer evidence)

| Layer | Evidence |
| --- | --- |
| Flutter MVP preserved | Riverpod, GoRouter, Drift, Freezed, Material 3 feeds |
| Backend modular monolith | `backend/` ASP.NET Core 8 + PostgreSQL + `/v1` OpenAPI |
| Ingestion (2–3) | Fixtures + **UN News** approved RSS; **GDELT** MetadataOnly discovery; ReliefWeb/WHO **restricted**; registry terms review — `docs/sources/source_registry.md`, `gdelt_constraints.md` |
| Clustering / scoring (4–5) | URL/hash dedupe, independent counts, World Pulse regional balance — `docs/methodology/*` |
| AI (6) | `IAiSynthesisService`: heuristic default + optional OpenAI-compatible GenAI (host env only; Flutter never holds keys) |
| Flutter remote (7) | `RemoteNewsRepository`, `APP_ENV`, typed `RemoteApiException`, retries, maintenance/min-version banners; production URL/env guards |
| Live-path ops | `/health`, `/ready`, `/v1/app/config`, docker-compose, staging smoke runbook |
| Map (8) | Natural Earth PD choropleth (hatch+icons), country detail panel, searchable list a11y — `docs/architecture/map_geojson.md` |
| Discovery (9) | Debounced search → `/v1/search`, filters, chips, empty states, server-driven paging |
| Offline (10) | Drift feed metadata cache (fresh/stale/expired); offline banners never present cache as live |
| Safety (11) | Reports allowlist + `report_rate_limited`; Ask/write limits; privacy/Data Safety drafts (**legal EXTERNAL**) |
| UI / a11y (12) | Story detail timeline/ranking/disputes/report/correction; British English labels |
| Admin | Ops token gate on ingestion run/metrics; fail closed outside Dev/Testing when unset |
| Observability (13) | Ingestion + API OTEL meters; TraceId HTTP logs; ops metrics API; optional Prometheus `/metrics` |
| CI (13–14) | Flutter + backend workflows; Android APK omitted until SDK runner — `docs/release/android_ci_notes.md` |
| Android release (14) | Signing checklist + Play dual-track docs; SDK probe; package blocked without `ANDROID_HOME` |

## Screenshots / demos — **GAP (SDK / device host)**

Screenshots and device recordings **have not been captured in this environment**. Cloud Agent / CI images lack Android SDK (`docs/release/android_sdk_blocker.md`); no APK/AAB was produced on Phase 14.

| # | Suggested capture | Why it matters |
| --- | --- | --- |
| 1 | World map + country list alternative | Choropleth not colour-alone; a11y path |
| 2 | Underreported feed + reason copy | Scoring honesty |
| 3 | Story detail (facts, timeline, disputes, Ask, report) | Phase 12 completeness |
| 4 | Offline / cache banner (“not a live feed”) | Phase 10 |
| 5 | Saved snapshot age notice | Local-only honesty |
| 6 | Settings: data mode, AI provider, privacy legal-draft note | Phase 7 + 11 |
| 7 | Empty states (no clusters vs filters) | Phase 9 |
| 8 | Maintenance / typed remote errors | Phase 7 |
| 9 | Demo banner on mock vs absent on remote | Dual-track honesty |

Until an SDK/device host exists, portfolio demos should cite **code + docs + CI tests**, not store screenshots.

## Methodology / architecture / release docs

| Area | Path |
| --- | --- |
| Ranking | `docs/methodology/world_pulse_ranking.md` |
| Underreported | `docs/methodology/underreported_methodology.md` |
| Sources | `docs/sources/source_registry.md`, `docs/sources/gdelt_constraints.md` |
| Backend | `docs/architecture/backend_decision.md` |
| Map licence | `docs/architecture/map_geojson.md`, `assets/geo/LICENSE.md` |
| Telemetry | `docs/architecture/telemetry.md` |
| Testing matrix | `docs/architecture/testing.md` |
| AI safety | `docs/ai_safety.md` |
| Privacy / Data Safety | `docs/privacy_policy.md`, `docs/play_data_safety.md` (**legal EXTERNAL**) |
| Corrections / abuse | `docs/editorial/corrections_policy.md`, `docs/editorial/abuse_prevention.md` |
| Staging smoke | `docs/release/staging_flutter_api_smoke.md` |
| Android | `docs/release/android_release.md`, `android_signing_checklist.md`, `android_ci_notes.md`, `android_sdk_blocker.md`, `play_console_checklist.md` |
| Store listing draft | `docs/play_store_listing.md` |
| Continue report | Agent store `internal/verimundi-live-news-report.md` (phases 2/3–14 appendices) |

## Verification available without device SDK

```bash
flutter test
cd backend && dotnet test
./scripts/check_android_sdk.sh   # expected exit 1 here — documents Phase 14 blocker
# optional: docker compose up + staging curl smoke when a URL exists
```

## Explicit non-claims

- Not yet a rights-cleared commercial news product (ReliefWeb/WHO restricted; commercial RSS unreviewed)
- Production RSS/GDELT flags stay off until ops opt-in + UN advise process
- Optional OpenAI-compatible GenAI behind host env; production key/cost controls still external; heuristic default without a key
- Privacy / Play Data Safety text is an **engineering draft** — counsel sign-off **EXTERNAL**
- Notifications not specified (truncated brief §26) — not invented
- Android production AAB/APK **not verified** here; screenshots **not captured** here
- Staging host URL and ops/GenAI secrets are operator-supplied (not in git)
- Choropleth uses Natural Earth public-domain 110m polygons only (see `assets/geo/LICENSE.md`)
