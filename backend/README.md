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
RSS and GDELT stay off unless explicitly flagged **and** sources are approved/enabled.

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
| `Ingestion:EnableGdelt` | Enable GDELT discovery scaffold (`true`/`false`; still no network until implemented + approved) |
| `Ingestion:FixturePath` | Override fixture JSON path |
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

Instruments live under meter `VeriMundi.Ingestion` (e.g. `verimundi_ingestion_articles_ingested`).  
OTLP exporter packages are not bundled here (known advisory on older OTLP packages); scrape Prometheus or attach a collector to `/metrics` instead.

Never commit real ops tokens. Do not put them in Flutter.

No news or GenAI secrets belong in the Flutter client.
