# VeriMundi REST API contract (`/v1`)

Flutter reads the base URL from:

```text
--dart-define=NEWS_API_BASE_URL=...
--dart-define=APP_ENV=development|staging|production
```

Default `NEWS_API_BASE_URL` is `mock` (local demo catalog).  
`APP_ENV=production` with `mock` is a hard configuration error (no silent fictional fallback).

## Endpoints

- `GET /health`
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

OpenAPI/Swagger is enabled for the Development environment on the ASP.NET host.
