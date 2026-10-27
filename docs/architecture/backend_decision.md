# Backend architecture decision

## Decision

VeriMundi uses a **modular monolith** built with:

| Layer | Choice |
| --- | --- |
| Runtime | .NET 8 |
| API | ASP.NET Core Minimal APIs / controllers under `/v1` |
| Data | PostgreSQL + EF Core |
| Hosting shape | Single deployable API host; background ingestion via hosted workers in-process (Workers project referenced by the host) |
| Secrets | Environment variables / .NET user-secrets / host secret store — **never** Flutter `--dart-define` |
| Docs | OpenAPI (Swagger) in Development |

## Why this stack

- Production-capable and familiar to a single-developer maintainer.
- Cheap to run initially (one API + one Postgres).
- Strong typing and testability for scoring, clustering, and AI contracts.
- Easy for agents: predictable project layout, `dotnet build` / `dotnet test`.
- PostgreSQL matches the brief and supports future full-text search.

## Explicit non-choices

- **No microservices** for ingestion, scoring, or AI — boundaries are modules inside one solution.
- **No GenAI or news credentials in the Flutter app.**
- **No indiscriminate scraping** of article HTML bodies.
- Client code generation from OpenAPI remains optional; Flutter keeps a hand-maintained Dio repository with schema-checked decoding for stories page, Ask, and app config.
- CI locks the Swagger document against `backend/contracts/openapi.v1.json` (regenerate via `backend/scripts/export-openapi.sh` after intentional breaks).

## Repository layout

```text
backend/
  VeriMundi.sln
  README.md
  src/
    VeriMundi.Api/             # HTTP, auth hooks, OpenAPI, DI composition
    VeriMundi.Application/     # use cases: ingestion orchestration, clustering, scoring, AI, search
    VeriMundi.Domain/          # entities, value objects, enums
    VeriMundi.Infrastructure/  # EF Core, providers (RSS, fixture, GDELT stub), AI providers
    VeriMundi.Workers/         # scheduled ingestion / re-scoring hosted services
  tests/
    VeriMundi.UnitTests/
    VeriMundi.IntegrationTests/
```

## Environments

| Name | Purpose |
| --- | --- |
| Development | Local Postgres, fixture ingestion enabled, Swagger on |
| Staging | Real approved sources + optional GenAI key |
| Production | Approved sources only; mock/fixture news disabled for public reads |

## Connection

Default local connection string (override via `ConnectionStrings__VeriMundi`):

```text
Host=localhost;Port=5432;Database=verimundi;Username=verimundi;Password=verimundi
```

## Evolution

Modules may later extract to separate processes only if operational pressure demands it. Until then, keep one database and one deployable.
