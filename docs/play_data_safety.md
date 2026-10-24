# Google Play Data Safety worksheet

Re-check this worksheet whenever permissions, SDKs, backend behaviour, or telemetry change.

## Release modes

| Mode | Data Safety posture |
| --- | --- |
| Mock demo (`NEWS_API_BASE_URL=mock`) | Local-only content; saved snapshots and optional feed cache stay on device |
| Remote (`NEWS_API_BASE_URL` = API) | Story metadata and optional Ask/Report payloads go to VeriMundi API |

## Data types

| Data type | Collected? | Shared? | Notes |
| --- | --- | --- | --- |
| Personal info (name, email) | No | No | No accounts |
| Location | No | No | Map uses story country coordinates, not device GPS |
| Photos / videos | No | No | |
| Files / docs | No | No | |
| User-generated content | Remote only | With VeriMundi backend | Optional Ask questions and problem reports |
| App activity / browsing | No analytics SDK today | No | |
| Device IDs / advertising IDs | No | No | |
| Saved story snapshots | Stored on device | No | User-initiated |
| Feed metadata cache | Stored on device | No | Age-labelled; no full article bodies |

## Security practices

- Encryption in transit: HTTPS required for production API URLs.
- Secrets: news/GenAI credentials stay on the backend only.
- Users can delete saved stories in-app; uninstall clears local DB.

## Checklist before production track

1. Confirm build dart-defines (`APP_ENV`, `NEWS_API_BASE_URL`) match the Play track.
2. Update this form if any telemetry or auth is added.
3. Complete legal review of `docs/privacy_policy.md`.
4. Do not ship production with mock news.
