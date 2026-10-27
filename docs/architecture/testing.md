# VeriMundi testing matrix

## What CI runs

| Workflow | Trigger | Commands |
| --- | --- | --- |
| `.github/workflows/flutter.yml` | PR + push `main` / `feat/**` | `dart format`, `flutter analyze`, `flutter test` |
| `.github/workflows/backend.yml` | PR + push when `backend/**` changes | `dotnet restore/build/test` (unit + integration) with Postgres 16 service for data-plane tests; separate OpenAPI contract job |

## Flutter (`test/features/`)

Coverage emphasis (not a % gate):

- Data mode / production mock forbid
- Remote repository search/paging/Ask/report error mapping
- Cache freshness + offline labels
- Feed empty states, filters, story detail a11y
- Map choropleth a11y (list alternative, severity text)
- Saved Drift repository

Run locally:

```bash
flutter test
```

## Backend

| Project | Focus |
| --- | --- |
| `VeriMundi.UnitTests` | Clustering, scoring, sources, AI validator/OpenAI stub, ingestion metrics store, report reasons |
| `VeriMundi.IntegrationTests` | `/health`, `/v1/app/config`, ops auth, Prometheus scrape, API telemetry, rate limits, OpenAPI contract, **Postgres data-plane** (stories paging, search, story-by-id, Ask heuristic, report allowlist/404) |

```bash
cd backend && dotnet test
```

Postgres data-plane tests seed + fixture-ingest inside the harness (`VERIMUNDI_TEST_POSTGRES` or Testcontainers). Hosted RSS/GDELT stay off under `Testing`. Live RSS/GDELT cycles still use docker-compose locally — see `backend/README.md`.

## Observability hooks under test

- Prometheus off → `/metrics` 404; on → ingestion + API meter names present after samples
- `ApiTelemetry.RouteGroup` classifications
- MeterListener asserts Ask / rate-limited counters emit

See `docs/architecture/telemetry.md`.

## Explicitly out of CI (EXTERNAL / host)

| Gap | Why |
| --- | --- |
| Device e2e / TalkBack / Play pre-launch | Needs Android SDK + device/emulator |
| APK / AAB packaging | Needs `ANDROID_HOME` + signing — `docs/release/android_ci_notes.md` |
| Staging API smoke against a real URL | Needs deployed base URL (`docs/release/staging_flutter_api_smoke.md`) |
| Load / soak of rate limits at the edge | Hosting/WAF, not in-process middleware alone |

Flutter CI runs an **informational** `./scripts/check_android_sdk.sh` step that always exits success for the job when the SDK is absent (documents the Phase 14 blocker without failing analyze/test).
