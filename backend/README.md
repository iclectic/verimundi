# VeriMundi backend

ASP.NET Core 8 modular monolith + PostgreSQL. See `docs/architecture/backend_decision.md`.

## Local run

Docker Compose (Postgres + API):

```bash
docker compose up --build
```

Or run the API against a local Postgres:

```bash
# Postgres (example local role created by agents/docs)
export ConnectionStrings__VeriMundi='Host=localhost;Port=5432;Database=verimundi;Username=verimundi;Password=verimundi'

cd backend
dotnet run --project src/VeriMundi.Api --urls http://0.0.0.0:5080
```

Swagger (Development): `http://localhost:5080/swagger`  
Health: `http://localhost:5080/health`  
Ready: `http://localhost:5080/ready`  
App config: `http://localhost:5080/v1/app/config`  
API root: `http://localhost:5080/v1/...`

On startup the API migrates, seeds countries/sources, and runs fixture ingestion.
Development enables RSS + GDELT flags; production `appsettings.json` keeps both **off** until ops opts in.
Only **approved + enabled** registry rows are ingested (UN News RSS today; GDELT MetadataOnly discovery).
ReliefWeb / WHO stay **restricted**. See `docs/sources/source_registry.md`.

## Tests

```bash
dotnet test
```

## Flutter remote mode

```bash
flutter run \
  --dart-define=NEWS_API_BASE_URL=http://localhost:5080 \
  --dart-define=APP_ENV=development
```

Production must never use `NEWS_API_BASE_URL=mock`.

Staging / remote honesty checklist (no secrets in git):  
`docs/release/staging_flutter_api_smoke.md` and `./scripts/staging_api_smoke.sh`.

## Configuration

| Key | Purpose |
| --- | --- |
| `ConnectionStrings:VeriMundi` | Postgres |
| `Ingestion:EnableRss` | Enable approved RSS provider (`true`/`false`) |
| `Ingestion:EnableGdelt` | Enable GDELT DOC 2.0 ArtList discovery (`true`/`false`; MetadataOnly — publisher rights still apply) |
| `Ingestion:GdeltQuery` | Optional GDELT DOC query (default `sourcelang:english`) |
| `Ingestion:FixturePath` | Override fixture JSON path |
| `Ai:ApiKey` / `OPENAI_API_KEY` | Optional OpenAI-compatible key (env only). Empty → heuristic synthesis/Ask |
| `Ai:BaseUrl` | OpenAI-compatible base (default `https://api.openai.com/v1`) |
| `Ai:Model` | Chat model id (default `gpt-4o-mini`) |
| `Ai:AskPerMinutePerIp` | Stricter Ask VeriMundi rate limit (default `10`) |
| `App:MaintenanceMode` | When `true`, product routes return `503`; health/ready/config/**admin** remain up |
| `App:MinimumAppVersion` | SemVer floor advertised to Flutter via `/v1/app/config` |
| `App:MaintenanceMessage` | Message returned during maintenance |
| `Ops:AdminIngestionToken` | Shared secret for `POST /v1/admin/ingestion/run`. Empty is allowed only in Development/Testing; Production/Staging fail closed until set |

### Admin ingestion

```bash
# Local Development with empty token (open):
curl -X POST http://localhost:5080/v1/admin/ingestion/run

# Staging/Production (required):
export Ops__AdminIngestionToken='…local secret…'
curl -X POST http://localhost:5080/v1/admin/ingestion/run \
  -H "X-VeriMundi-Ops-Token: $Ops__AdminIngestionToken"
# or: -H "Authorization: Bearer $Ops__AdminIngestionToken"

# Process-local counters (last run + totals since process start):
curl -fsS http://localhost:5080/v1/admin/ingestion/metrics \
  -H "X-VeriMundi-Ops-Token: $Ops__AdminIngestionToken"
```

Ingestion cycles emit structured log counters (`Fetched`, `Ingested`, `Duplicates`, `ClustersCreated`, `ProviderFailures`, …).

### Optional Prometheus scrape

Off by default. Enable to expose OpenTelemetry meters at `/metrics`:

```bash
export Telemetry__EnablePrometheus=true
# optional: Telemetry__PrometheusPath=/metrics
curl -fsS http://localhost:5080/metrics | head
```

Instruments live under meters `VeriMundi.Ingestion` and `VeriMundi.Api` (HTTP/Ask/reports/rate-limits).  
See `docs/architecture/telemetry.md` and `docs/architecture/testing.md`.  
OTLP exporter packages are not bundled here (known advisory on older OTLP packages); scrape Prometheus or attach a collector to `/metrics` instead.

Never commit real ops tokens. Do not put them in Flutter.

No news or GenAI secrets belong in the Flutter client.

### Optional grounded GenAI

Heuristic synthesis is the default (no key). To enable an OpenAI-compatible provider on the **backend only**:

```bash
export Ai__ApiKey='…local secret…'   # or OPENAI_API_KEY
# optional: Ai__BaseUrl=https://api.openai.com/v1
# optional: Ai__Model=gpt-4o-mini
```

`GET /v1/app/config` reports `ai.provider` as `heuristic` or `openaiCompatible` (never the key).  
Ask VeriMundi has an extra per-IP limit (`Ai:AskPerMinutePerIp`, code `ask_rate_limited`).  
Problem reports use an allowlisted reason set and an extra per-IP limit (`report_rate_limited`).  
See `docs/ai_safety.md` and `docs/editorial/abuse_prevention.md`.
