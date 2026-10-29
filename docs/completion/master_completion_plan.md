# VeriMundi master completion plan

Based on `docs/completion/current_state_audit.md` and the production brief (`internal/verimundi-production-plan.md`, §§1–25; §26+ truncated).

Working rule: implement sequentially; leave the repository functional after every phase; prefer Phases 0–7 as the first durable vertical slice. Do not commit or push unless explicitly authorised.

## External / incomplete brief

- §26 Notifications was truncated. Do not invent notification product requirements.
- Any sections after §26 are unknown until the full brief is supplied.
- Live news and GenAI require API keys, provider contracts, and source licence approvals (`docs/sources/source_registry.md`).
- Android APK builds require an Android SDK (`ANDROID_HOME`) not present in the current agent image.
- Licence for public distribution of VeriMundi itself is still undecided (`README.md`).

---

## Phase 0: Repository stabilisation

**Objective:** Make the repo agent-ready and keep the mock MVP green.

**Tasks:**
- Add `AGENTS.md` with project operating rules.
- Keep mock mode as the safe default.
- Preserve generated Freezed/Drift files via build_runner.
- Record environment baseline (format/analyze/test; APK blocked without SDK).
- Tighten `analysis_options.yaml` excludes introduced by tooling if useful.
- Clarify README that production work is in progress without claiming live news.

**Dependencies:** None.

**Files likely to change:** `AGENTS.md`, `README.md`, `analysis_options.yaml`, `docs/completion/*`.

**Tests:** Existing Flutter suite must remain green.

**Acceptance criteria:** Analyze/test pass; mock app still runs; rules documented.

**External blockers:** Android SDK for APK verification.

**Definition of done:** Docs + AGENTS present; MVP still demo-safe.

---

## Phase 1: Production backend foundation

**Objective:** Modular monolith API with PostgreSQL, clear boundaries, health and versioned `/v1` skeleton.

**Tasks:**
- Document stack choice in `docs/architecture/backend_decision.md`.
- Create `backend/` with Api / Application / Domain / Infrastructure / Workers.
- EF Core + PostgreSQL migrations for Source, Article, StoryCluster, links, claims.
- Configuration via environment / user-secrets (never Flutter dart-defines for secrets).
- OpenAPI / Swagger for `/v1`.
- Docker Compose optional; local Postgres supported.

**Dependencies:** Phase 0.

**Files:** `backend/**`, `docs/architecture/backend_decision.md`.

**Tests:** Domain unit tests; API smoke / health; migration applies cleanly.

**Acceptance criteria:** API boots against Postgres; `/v1` routes exist (even if empty); no secrets in Flutter.

**External blockers:** Hosted Postgres for non-local deploy (later).

**Definition of done:** Backend builds and serves health + empty/seed-capable contract endpoints.

---

## Phase 2: Real news ingestion

**Objective:** Provider-agnostic ingestion without scraping article bodies by default.

**Tasks:**
- `INewsProvider` / fetch latest abstraction.
- Fixture provider for deterministic local/dev.
- RSS provider for **approved** feeds only.
- Optional GDELT discovery adapter (metadata only) behind feature flag — validate API constraints before enabling in production.
- Scheduled worker / hosted service for ingestion cycles.
- Persist articles with content hashes; store permitted excerpts only.

**Dependencies:** Phase 1.

**Files:** `backend/src/Application/Ingestion/**`, `backend/src/Infrastructure/Ingestion/**`, `backend/src/Workers/**`.

**Tests:** Provider parsing unit tests; ingestion integration with fixture catalog.

**Acceptance criteria:** Ingestion run creates Article rows from approved providers; unapproved sources skipped.

**External blockers:** Provider API keys; feed licence approval.

**Definition of done:** At least fixture (+ optional RSS) path works end-to-end into DB.

---

## Phase 3: Normalisation and source registry

**Objective:** Canonical sources and normalised article metadata.

**Tasks:**
- Author `docs/sources/source_registry.md` with approval statuses.
- Seed registry in DB; only `approved` sources enabled for live reads.
- Canonical URL normalisation, language/country metadata, licence/attribution fields.
- Reject or quarantine restricted/rejected sources.

**Dependencies:** Phase 2.

**Files:** `docs/sources/source_registry.md`, source seed SQL/JSON, Infrastructure source services.

**Tests:** Registry filter tests; canonical URL normalisation tests.

**Acceptance criteria:** Live query path only surfaces approved sources; registry doc matches seed data.

**External blockers:** Legal review of each commercial source.

**Definition of done:** Registry doc + DB seed + enforcement in ingestion/API.

---

## Phase 4: Event clustering and deduplication

**Objective:** Cluster articles into story events before summarisation.

**Tasks:**
- Deduplicate by canonical URL / content hash.
- Cluster by normalised headline, time window, country, category; optional embedding hook later.
- `StoryArticleLink` with coverage class and similarity.
- Independent-source counting (not raw article count).

**Dependencies:** Phase 3.

**Files:** Clustering application services + tests.

**Tests:** Syndicated duplicates collapse; independent count < article count when lineage shared.

**Acceptance criteria:** Fixture ingest yields fewer clusters than raw articles; links recorded.

**External blockers:** Embedding provider (optional enhancement).

**Definition of done:** Clustering pipeline runs after ingestion and is covered by tests.

---

## Phase 5: Global importance and underreported scoring

**Objective:** Explainable World Pulse ranking and underreported scores.

**Tasks:**
- Port/extend underreported formula server-side with explanations.
- Regional balancing for World Pulse.
- Severity/tone separation; confidence and reasons.
- Docs: `docs/methodology/world_pulse_ranking.md`, `docs/methodology/underreported_methodology.md`.
- Constructive/positive impact scoring with evidence gates (conservative).

**Dependencies:** Phase 4.

**Files:** Scoring services, methodology docs, API feed ordering.

**Tests:** Score monotonicity fixtures; regional diversity reservation tests.

**Acceptance criteria:** Feeds return ordered clusters with human-readable reasons; no “media is ignoring” claims.

**External blockers:** Calibration data over time.

**Definition of done:** Documented algorithms + tested scoring applied to API feeds.

---

## Phase 6: Grounded AI synthesis

**Objective:** Backend-only GenAI (or deterministic synthesizer) with structured grounded output.

**Tasks:**
- `IAiSynthesisService` abstraction.
- Heuristic/deterministic synthesizer for zero-key environments.
- Optional OpenAI-compatible provider via env secrets.
- Structured JSON: summary, whyItMatters, confirmedFacts, disputedClaims, uncertainties, severity, tone, confidence, insufficientEvidence.
- Ask VeriMundi endpoint grounded on story evidence; rate limits + max input length.
- AI evaluation fixtures.
- Update `docs/ai_safety.md` for live path.

**Dependencies:** Phase 5.

**Files:** `backend/src/Application/Ai/**`, fixtures, AI safety docs.

**Tests:** Insufficient evidence; disputed claims not merged; no answer without sources.

**Acceptance criteria:** Synthesis never invents casualties; Flutter never holds GenAI keys.

**External blockers:** Production GenAI API key and cost controls.

**Definition of done:** Questions + summaries work via API with fixtures/heuristic without keys.

---

## Phase 7: Live Flutter integration

**Objective:** Real `RemoteNewsRepository` against `/v1`; production never silently falls back to mock.

**Tasks:**
- Implement Dio-backed remote repository matching expanded contract.
- `APP_ENV=development|staging|production` with explicit failure if production has mock base URL.
- Timeouts, retries, error mapping, cancellation, JSON validation, unknown enum fallback.
- Pagination hooks; stale cache markers where local cache exists.
- Keep `MockNewsRepository` for tests/demos.
- Update settings copy and demo banner gating by mode (demo banner only in mock/demo).

**Dependencies:** Phase 6 (or Phase 1+fixture data for thinner slice).

**Files:** `lib/core/**`, `lib/features/stories/data/**`, providers, tests, `docs/api_contract.md`.

**Tests:** Remote parsing unit tests with HTTP mocks; production config guard tests; existing mock tests remain.

**Acceptance criteria:** Pointing at local API loads live clusters; production+mock config fails loudly.

**External blockers:** Deployed staging URL for device testing.

**Definition of done:** Flutter can run mock **or** remote; remote path functional against local backend.

---

## Phase 8: World-map experience

**Objective:** Choropleth-style interactive map with accessible alternatives.

**Tasks:** Country polygons where practical; severity legend; list alternative; do not use colour alone.

**Dependencies:** Phase 7.

**Acceptance criteria:** Map + accessible list show consistent severity/story counts.

**External blockers:** ~~Suitable GeoJSON licence/asset~~ — cleared via Natural Earth public-domain 110m Admin-0 (vendored under `assets/geo/` with `LICENSE.md`).

---

## Phase 9: Search, filters and discovery

**Objective:** Real server-side search + richer filters with UX for empty/loading/error/reset.

**Dependencies:** Phase 7.

**Acceptance criteria:** Debounced remote search; active filter visibility; pagination.

**Status (2026-10-27):** Flutter `RemoteNewsRepository` routes text queries to `GET /v1/search`; browse stays on `/v1/stories`. Search applies category/severity/tone/verification/local-coverage. Feed shows page-of-total from server `total`; Next disabled when `!hasMore`. Filter chips are dismissible and reset page.

---

## Phase 10: Resilience, caching and offline behaviour

**Objective:** Fresh / stale-but-usable / expired cache semantics; never present old as live.

**Dependencies:** Phase 7.

**Acceptance criteria:** Offline saved + recent cache usable with age labels; no copyrighted full bodies stored.

**Hardened (2026-10-27):** Envelope cache persists `total`/`page`/`pageSize`; expired rows served offline with explicit “not a live feed” copy; `CacheStatusBanner` always visible when `fromCache` (including fresh); underreported/positive feeds cache + banner; saved rows labelled as local snapshots only.

---

## Phase 11: Privacy, safety and security

**Objective:** Update privacy / Play Data Safety for live networking; corrections policy; abuse prevention.

**Tasks:** `docs/editorial/corrections_policy.md`; report endpoint; auth/rate limits as needed.

**Dependencies:** Phases 6–7.

**External blockers:** Legal review of privacy policy text before store submission; production privacy contact email; Play Console Data Safety attestation by a human.

**Hardened (2026-10-27):** Live-path privacy + Data Safety drafts (IP rate-limit, Ask/report UGC, GenAI host path, offline cache); corrections + `abuse_prevention.md`; report reason allowlist; `report_rate_limited`; Flutter privacy notices + mock honesty; legal review still **EXTERNAL**.

---

## Phase 12: UI/UX and accessibility polish

**Objective:** Story detail completeness (timeline, ranking reason, disputes, report); a11y pass; British English copy.

**Dependencies:** Phases 7–11 for content; can polish mock UX earlier.

**Hardened (2026-10-27):** `NewsLabels` British English enum display; story detail full summary + correction banner + section headers/metrics semantics; Ask privacy copy; filter/map/card/saved human labels; story-detail a11y tests.

---

## Phase 13: Testing and observability

**Objective:** Expand unit/integration/e2e; structured logging/metrics on backend; CI for backend.

**Dependencies:** Phases 1–7.

**Hardened (2026-10-27):** `VeriMundi.Api` meters (HTTP/Ask/reports/rate-limits) + TraceId/RouteGroup request logs; Prometheus asserts API series; `docs/architecture/testing.md` + telemetry doc refresh; Flutter `report_reasons` test. Device e2e / staging URL still **EXTERNAL**.

---

## Phase 14: Android production release

**Objective:** Live (non-demo) Play track when remote path is honest and policy docs match.

**Dependencies:** Phases 7, 11, 13; signing secrets locally; Android SDK.

**External blockers:** Play Console account, keystore, privacy review, Android SDK in CI / Cloud Agent.

**Hardened without SDK (2026-10-27):** Re-probed blocker; `INTERNET` on main manifest for remote release; signing checklist + CI notes; dual-track Play listing/checklist; Flutter workflow informational SDK probe. **APK/AAB not built** — `ANDROID_HOME` unset.

---

## Phase 15: Portfolio and engineering evidence

**Objective:** Screenshots, architecture diagrams, methodology docs, honest changelog of mock→live.

**Dependencies:** Prior phases as available.

**Hardened (2026-10-27):** `docs/portfolio/engineering_evidence.md` refreshed for live-news stack Phases 2/3–14 (sources → Android docs); explicit screenshot/SDK gaps; doc index. Device captures still **EXTERNAL**.

---

## Execution status (this run)

| Phase | Status |
| --- | --- |
| 0 | **Done** — AGENTS.md, audit, completion docs, tooling baseline green |
| 1 | **Done** — ASP.NET Core modular monolith + Postgres + `/v1` + OpenAPI |
| 2 | **Done (fixture + live RSS/GDELT path)** — Fixture ingestion; RSS for **approved** feeds (`EnableRss` on in Development); GDELT DOC ArtList MetadataOnly discovery implemented behind `EnableGdelt` |
| 3 | **Done (terms-reviewed registry)** — UN News **approved**/enabled; GDELT **approved** MetadataOnly; ReliefWeb + WHO **restricted** (commercial/terms blocks — no fake clearance); curated seed sync; `docs/sources/gdelt_constraints.md` |
| 4 | **Done (v1)** — URL/hash dedupe + headline/day/country clustering + independent counts |
| 5 | **Done (v1)** — Underreported + World Pulse ranker + methodology docs |
| 6 | **Done (heuristic + optional GenAI)** — `IAiSynthesisService`; heuristic default; OpenAI-compatible provider via `Ai:ApiKey`/`OPENAI_API_KEY`; grounded JSON + Ask rate limit; eval fixtures |
| 7 | **Done + Phase 7 polish** — Remote client; production never silent-mock (incl. `prod`/blank/non-http guards); `/v1/app/config` + `ai.provider`; Ask uncertainty + `ask_rate_limited`; feed `page`/`pageSize` wired to API; typed remote errors |
| 8 | **Done (choropleth)** — Natural Earth **public-domain** 110m polygons vendored; severity fill+hatch+icons (not colour alone); country detail panel; list a11y retained — `docs/architecture/map_geojson.md` |
| 9 | **Done (hardened)** — Debounced discovery; Flutter uses `/v1/search` when query set; dismissible filter chips; server totals drive pagination; empty/error paths retained |
| 10 | **Done (hardened)** — Drift feed envelope cache (totals/page); serve expired offline with explicit non-live labels; banner always when fromCache; underreported/positive cache paths; saved snapshot honesty |
| 11 | **Done (hardened draft)** — Live-path privacy/Data Safety drafts; corrections + abuse docs; report allowlist + `report_rate_limited`; Flutter privacy/mock honesty; **legal review EXTERNAL** |
| 12 | **Done (hardened)** — Story detail completeness + correction banner; `NewsLabels` British English; section/card/map a11y; Ask/report honesty; story-detail a11y tests |
| 13 | **Done (hardened)** — Flutter+backend CI; TraceId HTTP logs; ingestion + **API** OTEL meters; Prometheus scrape; testing matrix doc; device e2e / staging URL **EXTERNAL** |
| 14 | **Blocked externally (docs hardened)** — No `ANDROID_HOME`; signing/CI/Play checklists ready; main manifest `INTERNET`; APK/AAB pending SDK host |
| 15 | **Done (docs hardened)** — Portfolio evidence covers live-news Phases 2/3–14; screenshot/APK gaps explicit; device/SDK host still **EXTERNAL** |
| §26+ | Blocked on complete brief — notifications not invented |

### Post–PR #1 continue milestone (live-path hardening)

**Implementable work completed on branch `cursor/verimundi-live-path-hardening-b049` (uncommitted unless later authorised):**

- `docker-compose.yml` for local Postgres + API
- `GET /ready`, `GET /v1/app/config`, `App:*` options, maintenance `503` middleware
- Flutter `RetryInterceptor`, `AppRemoteConfig`, `AppStatusBanners` / settings remote readiness
- Expanded **proposed** source registry + seed scaffolding (still disabled)
- Map GeoJSON blocker doc; Android SDK check script

### Continue slice: remote error taxonomy (2026-10-26)

**Chosen next item:** typed remote API error taxonomy (Phase 7 polish) — highest-value product/engineering work not blocked on Tubo/SDK/keys/§26.

**Delivered (still uncommitted):**

- `RemoteApiException` + kinds; Dio mapper; repository throws typed errors
- `AsyncValueView` kind-specific titles/icons/recovery hints
- Ask + report surfaces use the same taxonomy
- Rate-limit middleware returns JSON `{code: rate_limited, message}` + Retry-After
- Contract table + unit/widget coverage

### Continue slice: feed empty-state polish (2026-10-26)

**Chosen next item:** empty-state polish for zero remote clusters vs filters (Phases 9/12) — licence-safe, unblocked.

**Delivered (still uncommitted):**

- `FeedEmptyReason` + `resolveFeedEmptyReason` (noClusters / filteredOut / modeEmpty / endOfPages)
- Shared `FeedEmptyState` with reset / World Pulse / previous-page actions
- World, Underreported, Positive screens wired; underreported applies `StoryFiltering`
- `StoryFilter.hasActiveConstraints` + tests

### Continue slice: map country-list a11y polish (2026-10-26)

**Chosen next item:** Phase 8/12 country-list accessibility polish — no GeoJSON dependency.

**Delivered (still uncommitted):**

- Country list search (name/code/region), sort (severity / name / active stories)
- Active-only + severity FilterChips (icon + text), live result count
- Empty list reset (+ clear region when a region chip is active)
- Title switches to “Country list”; region chip group labelled for AT
- Tests expanded in `world_map_accessibility_test.dart`; `map_geojson.md` updated

### Continue slice: admin ops auth gate (2026-10-26)

**Branch:** `cursor/verimundi-admin-ops-auth-b049` (from hardening tip `ed7bb4d`; live-path PR not yet on `main`).

**Chosen next item:** ops auth gate on `POST /v1/admin/ingestion/run`.

**Delivered (uncommitted unless later authorised):**

- `OpsAuthOptions` + `OpsAdminAuth` (header / Bearer, fixed-time compare)
- Fail closed when token empty outside Development/Testing; open locally when unset
- Admin path exempt from maintenance middleware (still token-gated)
- Docs: API contract, backend README, docker-compose env stub
- Integration/unit-style coverage in `OpsAdminAuthTests`

### Continue slice: staging Flutter→API smoke runbook (2026-10-26)

**Chosen next item:** staging smoke runbook (no secrets in repo).

**Delivered (uncommitted on `cursor/verimundi-admin-ops-auth-b049`):**

- `docs/release/staging_flutter_api_smoke.md` — curl + Flutter remote checklist, ops token via env, honesty/empty/maintenance drills
- `scripts/staging_api_smoke.sh` — env-driven curl smoke (`STAGING_API_BASE_URL`, optional ops token)
- Cross-links from backend README + Android SDK blocker doc

### Continue slice: ingestion metrics/logging counters (2026-10-26)

**Chosen next item:** ingestion run metrics + structured logging counters.

**Delivered (uncommitted on `cursor/verimundi-admin-ops-auth-b049`):**

- Expanded `IngestionResult` counters (fetched, duplicates, unapproved/restricted skips, clusters created/attached, synthesises, provider failures, duration, trigger)
- `IngestionMetricsStore` process-local totals + last run; recorded by pipeline / hosted failure path
- Structured completion logs; `GET /v1/admin/ingestion/metrics` (ops-gated)
- Unit + integration coverage; docs/runbook/README updated

### Continue slice: OTEL / Prometheus export (2026-10-26)

**Chosen next item:** optional OpenTelemetry meters + Prometheus scrape for ingestion counters.

**Delivered (uncommitted on `cursor/verimundi-admin-ops-auth-b049`):**

- `IngestionTelemetry` System.Diagnostics.Metrics instruments (wired from `IngestionMetricsStore`)
- `Telemetry:EnablePrometheus` / `Telemetry__EnablePrometheus` → `GET /metrics` (default off)
- OpenTelemetry.Extensions.Hosting + Prometheus AspNetCore exporter (OTLP package omitted due to advisory)
- `docs/architecture/telemetry.md`; API/README/compose updates; integration tests

### Continue slice: portfolio evidence refresh + decision gate (2026-10-26)

**Assessment:** High-value **unblocked** engineering items from the post–PR #1 continue chain are complete (live-path, errors, empty states, map list a11y, ops auth, staging runbook, ingestion metrics, Prometheus). No further product scope invented.

**Delivered this check:** refreshed `docs/portfolio/engineering_evidence.md` to match the dirty ops-auth stack (docs-only accuracy, Phase 15).

**Next action (not inventable here):** Tubo authorises **commit/push/PR** of:
1. `cursor/verimundi-live-path-hardening-b049` (already pushed @ `ed7bb4d`) merge into `main`, and/or  
2. `cursor/verimundi-admin-ops-auth-b049` (dirty: ops auth + runbook + metrics + Prometheus).

### Continue slice: live news source terms review (2026-10-26)

**Chosen:** Phase 2/3 — approve only where posted terms clearly allow VeriMundi metadata/RSS use; enable RSS for approved; GDELT MetadataOnly with constraints; no fake legal approval.

**Delivered on `cursor/verimundi-live-news-sources-b049` (no commit unless authorised):**

- UN News **approved** + enabled (RSS excerpt + attribution + advise-UN ops note)
- GDELT DOC ArtList **approved** MetadataOnly + live provider (publisher domains still gated)
- ReliefWeb + WHO **restricted** (commercial / written-permission blocks)
- Registry + seed sync + `gdelt_constraints.md` + unit tests

### Continue slice: Phase 6 grounded GenAI (2026-10-27)

**Chosen:** Optional OpenAI-compatible `IAiSynthesisService` behind env secrets; heuristic default; grounded Ask + synthesis; Ask rate limit; ai_safety + eval fixtures.

**Delivered (same dirty branch `cursor/verimundi-live-news-sources-b049`, no commit unless authorised):**

- `AiOptions` + `OpenAiCompatibleSynthesisService` + `GroundedAiValidator`
- DI selects GenAI when `Ai:ApiKey` / `OPENAI_API_KEY` set; else heuristic
- `AskRateLimitMiddleware` (`ask_rate_limited`); `/v1/app/config` → `ai.provider`
- Fixtures `ai_eval_cases.json` + unit tests; Flutter reads `aiProvider` (no secrets)

### Continue slice: Phase 7 live Flutter polish (2026-10-27)

**Chosen:** Close remaining Phase 7 gaps on the dirty live-news branch (no commit).

**Already done earlier (not reimplemented):** Dio `RemoteNewsRepository`, production+mock misconfig throw, retries, `RemoteApiException`, demo banner gating, settings data-mode copy, basic remote parse tests.

**Shipped this polish:** production URL/env guards; `ai.provider` in settings AI tile; Ask uncertainty + longer timeout + client question validation; `ask_rate_limited` mapping; feed `page`/`pageSize` to `/v1/stories`; tests.

### Continue slice: Phase 8 world map choropleth (2026-10-27)

**Chosen:** Licence-safe GeoJSON choropleth (Natural Earth public domain) + country detail panel; severity not colour-alone; keep list a11y.

**Delivered (dirty `cursor/verimundi-live-news-sources-b049`, no commit):** `assets/geo/countries_110m.geojson` + `LICENSE.md`; `ChoroplethMap` hatch+icons; `CountryDetailPanel`; docs/plan updates.

### Continue slice: Phase 9 search/filters/discovery (2026-10-27)

**Chosen:** Harden real search against `/v1/search`, filters, debounce, empty/error/pagination.

**Delivered (same dirty branch, no commit):** Flutter routes query → `/v1/search`; backend search filters completed; `StoryPageResult` + feed totals; dismissible chips; page reset on filter change; Next gated by `hasMore`.

**Still external / Tubo decisions (required before more product work):**

| Decision | Blocks |
| --- | --- |
| Written OCHA/ReliefWeb clearance for product aggregation | ReliefWeb RSS enablement |
| Written WHO authorisation for commercial product use | WHO RSS enablement |
| Production opt-in (`EnableRss`/`EnableGdelt`) + advise UN (`unnews@un.org`) | Production live feeds |
| Production GenAI key + spend/cost controls | Non-heuristic production synthesis |
| Privacy / Play Data Safety legal sign-off | Store submission honesty |
| Product licence for public distribution | README / release posture |
| Full brief §26+ (notifications) | Push product — **do not invent** |
| Android SDK + signing host | Phase 14 APK/AAB verification |
| ~~Licence-safe GeoJSON~~ | Cleared — Natural Earth PD 110m vendored |
| Staging API base URL | Executing the smoke runbook end-to-end |
| OTLP NuGet advisory clearance | Optional OTLP exporter (Prometheus scrape already available) |
| Commit/push authorisation for dirty ops-auth stack | PR of current work |

**Not committed / not pushed** (per authorisation gate).
