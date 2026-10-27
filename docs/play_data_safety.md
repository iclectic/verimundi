# Google Play Data Safety worksheet

Re-check this worksheet whenever permissions, SDKs, backend behaviour, or telemetry change.

**Status:** Engineering draft aligned to the current codebase. **Legal / Play Console review is an EXTERNAL BLOCKER** before production track submission. Answers below must be confirmed by a human against the final build’s dart-defines and backend flags.

## Release modes

| Mode | Data Safety posture |
| --- | --- |
| Mock demo (`NEWS_API_BASE_URL=mock`) | Local-only content; saved snapshots and optional feed cache stay on device; Ask/reports are not sent |
| Remote (`NEWS_API_BASE_URL` = API) | Story metadata GETs; optional Ask questions and problem reports POSTed to VeriMundi API (rate-limited) |

## Data types (Play form mapping)

| Data type | Collected? | Shared? | Notes |
| --- | --- | --- | --- |
| Personal info (name, email, phone) | No | No | No accounts |
| Location | No | No | Map uses story country coordinates, not device GPS |
| Photos / videos | No | No | |
| Files / docs | No | No | |
| User-generated content | Remote only | With VeriMundi backend (and optionally the operator’s GenAI provider when enabled) | Ask questions; problem-report free-text details |
| App activity / browsing history | No analytics SDK today | No | No Firebase Analytics / Ads in current tree |
| Device or other IDs / advertising IDs | No advertising ID | No | Client IP processed server-side for rate limiting only — not an advertising ID; declare per counsel guidance if Play treats IP as “device or other IDs” |
| Saved story snapshots | Stored on device | No | User-initiated |
| Feed metadata cache | Stored on device | No | Age-labelled; no full article bodies |

### Purposes (when remote UGC is collected)

- App functionality: Ask VeriMundi grounded answers; editorial problem reports for corrections.
- Fraud prevention / security / abuse: rate limits on write/Ask/report endpoints (`rate_limited`, `ask_rate_limited`, `report_rate_limited`).

### Ephemeral processing

Rate limiting uses client IP in short in-memory windows on the API process. This is not sold and is not used for ads.

## Security practices

- Encryption in transit: HTTPS required for production API URLs (`APP_ENV=production` rejects non-http(s) bases).
- Secrets: news/GenAI/ops credentials stay on the backend only; Flutter never holds them.
- Users can delete saved stories in-app; uninstall clears local DB.
- Report free-text is not echoed into application logs (length only).

## Account deletion

No user accounts exist; there is no account-deletion flow. Local data is removable via in-app unsaving and uninstall.

## Checklist before production track

1. Confirm build dart-defines (`APP_ENV`, `NEWS_API_BASE_URL`) match the Play track — never ship production with mock news.
2. Update this form if any telemetry, auth, crash SDK, or GenAI provider change lands.
3. Complete **legal review** of `docs/privacy_policy.md` (**EXTERNAL**).
4. Supply production privacy contact email (**EXTERNAL**).
5. Confirm Data Safety form answers in Play Console match this worksheet for the exact binary.
6. Confirm ops Auth token is set outside Development/Testing so admin ingestion stays fail-closed.
