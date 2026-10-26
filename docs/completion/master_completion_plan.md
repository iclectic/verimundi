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

**External blockers:** Suitable GeoJSON licence/asset.

---

## Phase 9: Search, filters and discovery

**Objective:** Real server-side search + richer filters with UX for empty/loading/error/reset.

**Dependencies:** Phase 7.

**Acceptance criteria:** Debounced remote search; active filter visibility; pagination.

---

## Phase 10: Resilience, caching and offline behaviour

**Objective:** Fresh / stale-but-usable / expired cache semantics; never present old as live.

**Dependencies:** Phase 7.

**Acceptance criteria:** Offline saved + recent cache usable with age labels; no copyrighted full bodies stored.

---

## Phase 11: Privacy, safety and security

**Objective:** Update privacy / Play Data Safety for live networking; corrections policy; abuse prevention.

**Tasks:** `docs/editorial/corrections_policy.md`; report endpoint; auth/rate limits as needed.

**Dependencies:** Phases 6–7.

**External blockers:** Legal review of privacy policy text before store submission.

---

## Phase 12: UI/UX and accessibility polish

**Objective:** Story detail completeness (timeline, ranking reason, disputes, report); a11y pass; British English copy.

**Dependencies:** Phases 7–11 for content; can polish mock UX earlier.

---

## Phase 13: Testing and observability

**Objective:** Expand unit/integration/e2e; structured logging/metrics on backend; CI for backend.

**Dependencies:** Phases 1–7.

---

## Phase 14: Android production release

**Objective:** Live (non-demo) Play track when remote path is honest and policy docs match.

**Dependencies:** Phases 7, 11, 13; signing secrets locally; Android SDK.

**External blockers:** Play Console account, keystore, privacy review, Android SDK in CI.

---

## Phase 15: Portfolio and engineering evidence

**Objective:** Screenshots, architecture diagrams, methodology docs, honest changelog of mock→live.

**Dependencies:** Prior phases as available.

---

## Execution status (this run)

| Phase | Status |
| --- | --- |
| 0 | **Done** — AGENTS.md, audit, completion docs, tooling baseline green |
| 1 | **Done** — ASP.NET Core modular monolith + Postgres + `/v1` + OpenAPI |
| 2 | **Done (fixture path)** — Fixture ingestion live; RSS provider present, off by default; GDELT discovery scaffold gated (`EnableGdelt=false`) |
| 3 | **Done (initial + proposals)** — Registry + DB seed + approval gating; UN/ReliefWeb/WHO/GDELT rows seeded as **proposed/disabled** with idempotent upsert |
| 4 | **Done (v1)** — URL/hash dedupe + headline/day/country clustering + independent counts |
| 5 | **Done (v1)** — Underreported + World Pulse ranker + methodology docs |
| 6 | **Done (heuristic)** — `IAiSynthesisService` + heuristic provider (no GenAI key required) |
| 7 | **Done + hardened** — Remote client + `/ready` + `/v1/app/config` + maintenance middleware + Flutter retries (no 503 retry) + maintenance/min-version banners + settings readiness + **typed `RemoteApiException` taxonomy** (maintenance/rate-limit/timeout/offline/server) wired through repository, feeds, Ask, and report |
| 8 | **Done (v1 + list a11y polish)** — Interactive map + searchable/sortable country list (severity chips, active-only, live counts); GeoJSON choropleth still blocked — see `docs/architecture/map_geojson.md` |
| 9 | **Done (v1)** — Debounced search, richer filters, active chips, empty state, page controls; **empty-state polish** distinguishes no clusters / filtered out / mode empty / end of pages |
| 10 | **Done (v1)** — Drift feed metadata cache with fresh/stale/expired labels; saved snapshot age notice |
| 11 | **Done (draft)** — Privacy/Data Safety updated for dual mode; report API + rate limit; legal review still external |
| 12 | **Done (v1)** — Timeline, save/report actions, British English empty copy, map a11y; shared `FeedEmptyState`; country-list search/sort/severity filters (not colour alone) |
| 13 | **Done (v1)** — Extra Flutter tests; backend CI workflow; request logging middleware; docker-compose local stack |
| 14 | **Blocked externally** — No Android SDK/`ANDROID_HOME`; probe via `scripts/check_android_sdk.sh` |
| 15 | **Done (docs)** — `docs/portfolio/engineering_evidence.md` (screenshots still need a device/SDK host) |
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

**Next implementable candidate:** ops auth gate for `/v1/admin/ingestion/run` (env token / header; keep fixture path local-dev friendly).

**Still external / Tubo decisions:**

- Approve/reject proposed sources; GenAI production key; privacy/legal; product licence; Android SDK host; full brief §26+ notifications
- Licence-safe GeoJSON asset for choropleth

**Not committed / not pushed** (per authorisation gate).
