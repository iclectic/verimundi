# VeriMundi backend

ASP.NET Core 8 modular monolith + PostgreSQL. See `docs/architecture/backend_decision.md`.

## Local run

```bash
# Postgres (example local role created by agents/docs)
export ConnectionStrings__VeriMundi='Host=localhost;Port=5432;Database=verimundi;Username=verimundi;Password=verimundi'

cd backend
dotnet run --project src/VeriMundi.Api --urls http://0.0.0.0:5080
```

Swagger (Development): `http://localhost:5080/swagger`  
Health: `http://localhost:5080/health`  
API root: `http://localhost:5080/v1/...`

On startup the API migrates, seeds countries/sources, and runs fixture ingestion.

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
| `Ingestion:FixturePath` | Override fixture JSON path |

No news or GenAI secrets belong in the Flutter client.
