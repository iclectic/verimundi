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

## Configuration

| Key | Purpose |
| --- | --- |
| `ConnectionStrings:VeriMundi` | Postgres |
| `Ingestion:EnableRss` | Enable approved RSS provider (`true`/`false`) |
| `Ingestion:EnableGdelt` | Enable GDELT discovery scaffold (`true`/`false`; still no network until implemented + approved) |
| `Ingestion:FixturePath` | Override fixture JSON path |
| `App:MaintenanceMode` | When `true`, product routes return `503`; health/ready/config remain up |
| `App:MinimumAppVersion` | SemVer floor advertised to Flutter via `/v1/app/config` |
| `App:MaintenanceMessage` | Message returned during maintenance |

No news or GenAI secrets belong in the Flutter client.
