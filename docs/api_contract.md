# VeriMundi REST API contract (`/v1`)

Flutter reads the base URL from:

```text
--dart-define=NEWS_API_BASE_URL=...
--dart-define=APP_ENV=development|staging|production
```

Default `NEWS_API_BASE_URL` is `mock` (local demo catalog).  
`APP_ENV=production` with `mock` is a hard configuration error (no silent fictional fallback).

## Endpoints

- `GET /health` — liveness (process up)
- `GET /ready` — readiness (Postgres reachable); `503` when DB is down
- `GET /v1/app/config` — remote client config (`maintenanceMode`, `minimumAppVersion`, ingestion flags, disclaimer). Available even during maintenance.
- `GET /v1/world/status`
- `GET /v1/regions`
- `GET /v1/countries`
- `GET /v1/countries/{countryCode}`
- `GET /v1/countries/{countryCode}/stories`
- `GET /v1/stories`
- `GET /v1/stories/{storyId}`
- `GET /v1/stories/{storyId}/sources`
- `GET /v1/stories/{storyId}/claims`
- `GET /v1/stories/{storyId}/history`
- `GET /v1/stories/underreported`
- `GET /v1/stories/positive`
- `GET /v1/search`
- `POST /v1/stories/{storyId}/questions`
- `POST /v1/stories/{storyId}/reports`
- `POST /v1/admin/ingestion/run` (ops; protect before public deploy)

List endpoints return:

```json
{ "items": [], "page": 1, "pageSize": 20, "total": 0 }
```

Errors use:

```json
{ "code": "story_not_found", "message": "Story was not found." }
```

Common codes the Flutter client maps into typed UI states:

| HTTP | `code` | Client kind |
| --- | --- | --- |
| 503 | `maintenance` | Maintenance (Retry-After respected when present) |
| 429 | `rate_limited` | Rate limited (write endpoints; Retry-After ≈ 60s) |
| 404 | `story_not_found` / `country_not_found` | Not found |
| 4xx | other | Bad request |
| 5xx | other | Server error |

Transport failures (timeout / connection) never silently fall back to mock in production.

OpenAPI/Swagger is enabled for the Development environment on the ASP.NET host.
