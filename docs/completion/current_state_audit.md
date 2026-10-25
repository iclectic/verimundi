# VeriMundi current-state audit

Audit date: 2026-10-24  
Branch: `feat/verimundi-mvp` @ `7f00674`  
Auditor notes: Verified against source code, not documentation alone. Flutter was not present in the environment image and was installed locally for this audit (`~/flutter`, stable 3.47.8 / Dart 3.13.7).

## Baseline commands

| Command | Result |
| --- | --- |
| `flutter pub get` | Pass (updated `pubspec.lock` resolution; Flutter also patched `analysis_options.yaml` with platform excludes) |
| `dart run build_runner build` | Pass (wrote generated outputs; `--delete-conflicting-outputs` ignored by current build_runner) |
| `dart format --output=none --set-exit-if-changed .` | Pass (0 files changed) |
| `flutter analyze` | Pass (no issues) |
| `flutter test` | Pass (16 tests) |
| `flutter build apk --debug` | **Fail** — no Android SDK / `ANDROID_HOME` in this environment |

Git status at audit start: clean. After tooling: dirty `analysis_options.yaml`, `pubspec.lock` only.

## Classification legend

- **COMPLETE** — production-ready for the claimed behaviour
- **FUNCTIONAL BUT NEEDS POLISH** — works for MVP/demo, needs product hardening
- **MOCK ONLY** — deliberately fictional / local fixtures
- **PARTIAL** — real structure present, incomplete behaviour
- **MISSING** — not present
- **BLOCKED EXTERNALLY** — needs keys, licences, SDKs, or truncated brief

---

## Major areas

### Flutter application shell
**FUNCTIONAL BUT NEEDS POLISH**

- Material 3 app, Riverpod, GoRouter shell with World / Underreported / Positive / Saved + Settings and story detail.
- Bootstrap is minimal (`WidgetsFlutterBinding` + error present). No crash reporting, no env-aware banners beyond demo mode.
- `pubspec.yaml` description still reads “A new Flutter project.”

### Themes and UI chrome
**FUNCTIONAL BUT NEEDS POLISH**

- Light/dark themes exist (`app_theme.dart`).
- Demo banner is correctly pervasive for honesty.
- Map is marker-on-placeholder, not choropleth (§21).
- Story detail covers summary, facts, uncertainty, coverage, sources, mock Ask, save — missing timeline, ranking explanation UI, dispute block, report flow, correction notice.

### World Pulse / underreported / positive feeds
**MOCK ONLY** (UI: **FUNCTIONAL BUT NEEDS POLISH**)

- Feeds load from `MockNewsRepository` + `assets/mock/verimundi_mock_catalog.json` (20 countries, 30 seeds).
- Underreported score is deterministic client-side (`UnderreportedScoringService`) but fed by mock counts.
- Positive feed is tone filter + seed `positiveImpactScore`, not evidence-based classification.

### Story models and filtering
**FUNCTIONAL BUT NEEDS POLISH**

- Freezed models cover cluster, sources, facts, filters, saved snapshots, AI answers.
- Local filtering/search works in-memory; no remote search, pagination, or debounce.
- Missing production fields: independent source count, disputed claims, ranking reasons, correction metadata, cache freshness.

### Persistence (saved stories)
**FUNCTIONAL BUT NEEDS POLISH**

- Drift/SQLite snapshots work with unit coverage.
- No “snapshot may be older than server” indicator against a live API.
- No feed/offline metadata cache beyond saved rows.

### Networking / remote repository
**PARTIAL** / intentionally unavailable

- `ApiClient` + Dio exist; `AppDataMode` is only `mock | remoteUnavailable`.
- `RemoteNewsRepository` throws `StateError` for every method.
- Non-mock `NEWS_API_BASE_URL` does **not** silently fall back to mock (good), but also cannot serve live data.
- No `APP_ENV`, retries, maintenance mode, min app version, rate-limit mapping, or OpenAPI client.

### Ask VeriMundi / GenAI
**MOCK ONLY**

- `MockStoryQuestionService` and `MockGenAiSummaryService` only.
- Client never holds GenAI secrets (good).
- No backend synthesis, structured disputed claims, or evaluation fixtures.

### Backend / ingestion / clustering / scoring
**MISSING**

- No `backend/` tree, no PostgreSQL schema, no workers, no source registry implementation, no OpenAPI server.

### Source strategy and licences
**MISSING** (docs) / **BLOCKED EXTERNALLY** (live rights)

- No `docs/sources/source_registry.md`.
- Commercial news bodies must not be scraped; approved feeds and provider keys are external blockers.

### World map
**PARTIAL**

- Lat/long icon markers with semantics and country bottom sheet.
- No country polygons, choropleth, severity legend as a first-class control, or regional navigation beyond filters.

### Privacy, safety, Play release docs
**FUNCTIONAL BUT NEEDS POLISH** (for **demo** release) / **PARTIAL** (for live product)

- `docs/ai_safety.md`, privacy, Play Data Safety, listing, Android release runbook exist and match mock behaviour.
- Signing config reads optional `android/key.properties` (file absent in repo — correct).
- Live backend will invalidate current Data Safety / privacy answers until updated.

### Testing and CI
**FUNCTIONAL BUT NEEDS POLISH**

- Unit + widget + accessibility tests pass; integration_test scaffold exists but is not in CI.
- GitHub Actions: format, analyze, test on `main` and `feat/**`.
- No backend CI; no golden/screenshot set committed.

### Notifications (§26+)
**MISSING** / **BLOCKED EXTERNALLY**

- Brief truncated mid-§26. Do not invent notification product requirements.

---

## TODO / risk search summary

| Pattern | Finding |
| --- | --- |
| `TODO` / `FIXME` / `HACK` | None in Dart sources |
| `UnimplementedError` | None in production paths |
| `StateError` | Used deliberately by unavailable remote repository and error UI tests |
| Hard-coded secrets | None found in client |
| Mock / demo | Pervasive and intentional |
| Dead remote path | `RemoteNewsRepository` is a hard failure stub |

---

## Honest product status

VeriMundi today is a **production-quality demo MVP**: polished Flutter UX over fictional catalog data, with strong AI-safety *intent* documentation and an honest demo posture. It is **not** a live news product. The gap to production is primarily backend ingestion, rights-cleared sources, clustering/scoring, grounded AI, and a real remote Flutter client — not a rewrite of the Flutter feature architecture.
