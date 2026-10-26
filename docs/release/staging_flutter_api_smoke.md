# Staging Flutter → API smoke runbook

Manual checklist to prove the **remote** Flutter client talks honestly to a deployed (or local-compose) VeriMundi API.  
**Do not commit secrets.** Use shell environment variables or a private password manager.

Related: `docs/api_contract.md`, `backend/README.md`, `docs/release/android_sdk_blocker.md`, ops gate on `POST /v1/admin/ingestion/run`.

---

## Preconditions

| Item | Notes |
| --- | --- |
| API reachable | HTTPS preferred for shared staging; `http://localhost:5080` OK for compose |
| Postgres migrated + seeded | Fixture path OK for staging honesty if labelled; production sources need Tubo approval |
| Flutter SDK | `flutter doctor` green for the target device (web / desktop / Android if SDK present) |
| Secrets out of git | Ops token, DB passwords, GenAI keys — env only |

Placeholders used below (replace locally; never paste real values into PRs):

```bash
export STAGING_API_BASE_URL='https://api.staging.example'   # no trailing slash
export Ops__AdminIngestionToken='…local only…'              # optional for admin step
```

---

## 1. API liveness / readiness (curl)

From any machine that can reach staging:

```bash
# Or: ./scripts/staging_api_smoke.sh
curl -fsS "$STAGING_API_BASE_URL/health"
curl -fsS "$STAGING_API_BASE_URL/ready"
curl -fsS "$STAGING_API_BASE_URL/v1/app/config"
```

**Expect**

| Call | Success |
| --- | --- |
| `/health` | `200`, JSON includes `"status":"ok"` |
| `/ready` | `200` `"status":"ready"` (or `503` if DB down — fix before Flutter smoke) |
| `/v1/app/config` | `200` with `maintenanceMode`, `minimumAppVersion`, `ingestion.enableRss` / `enableGdelt` |

**Record:** environment name from config, whether maintenance is off, min app version vs client `AppConstants.appVersion` (`1.0.0` unless bumped).

---

## 2. Feed contract smoke (curl)

```bash
curl -fsS "$STAGING_API_BASE_URL/v1/world/status"
curl -fsS "$STAGING_API_BASE_URL/v1/countries" | head -c 400; echo
curl -fsS "$STAGING_API_BASE_URL/v1/stories?page=1&pageSize=5" | head -c 600; echo
```

**Expect:** JSON shapes per `docs/api_contract.md` (`items` / `page` / `pageSize` / `total` on lists).  
Empty `items` with filters off is a valid “no clusters yet” outcome — Flutter should show the **no clusters** empty state, not invent stories.

---

## 3. Ops ingestion (optional, token-gated)

Only if you intend to re-run fixture/approved ingestion:

```bash
# Missing/wrong token → 401 ops_unauthorized (when token is configured)
curl -sS -o /tmp/vm-ops.json -w '%{http_code}\n' -X POST \
  "$STAGING_API_BASE_URL/v1/admin/ingestion/run"

# Correct token (header or Bearer) — never log the token
curl -fsS -X POST "$STAGING_API_BASE_URL/v1/admin/ingestion/run" \
  -H "X-VeriMundi-Ops-Token: ${Ops__AdminIngestionToken}"

curl -fsS "$STAGING_API_BASE_URL/v1/admin/ingestion/metrics" \
  -H "X-VeriMundi-Ops-Token: ${Ops__AdminIngestionToken}"
```

On shared staging, `Ops:AdminIngestionToken` **must** be set (fail closed).  
Local `docker compose` Development may leave the token empty (open) — do not copy that posture to public staging.  
Metrics JSON is process-local (reset on API restart). For scrapes, optionally set `Telemetry__EnablePrometheus=true` and hit `/metrics` (see `docs/architecture/telemetry.md`).

---

## 4. Flutter remote client

Point the app at staging **without** mock:

```bash
flutter run \
  --dart-define=APP_ENV=staging \
  --dart-define=NEWS_API_BASE_URL="$STAGING_API_BASE_URL"
```

Web / desktop alternatives if Android SDK is missing:

```bash
flutter run -d chrome \
  --dart-define=APP_ENV=staging \
  --dart-define=NEWS_API_BASE_URL="$STAGING_API_BASE_URL"

flutter run -d linux \
  --dart-define=APP_ENV=staging \
  --dart-define=NEWS_API_BASE_URL="$STAGING_API_BASE_URL"
```

**Negative control (must fail loud, not fall back to fiction):**

```bash
# Expect startup StateError — production + mock is forbidden
flutter run \
  --dart-define=APP_ENV=production \
  --dart-define=NEWS_API_BASE_URL=mock
```

---

## 5. In-app checklist

| Check | Pass criteria |
| --- | --- |
| Demo banner | **Hidden** in remote mode (only mock shows the demo honesty banner) |
| Settings → Data mode | Mentions remote API / staging URL (not “Mock data mode”) |
| Settings → Remote API readiness | Loads `/v1/app/config`; maintenance off; min version OK |
| World Pulse | Stories load **or** honest empty state (“No stories available yet” / filter empty) — never silent mock |
| Pull to refresh | Recovers from transient errors; typed errors for offline / timeout / 503 |
| Country list | Map → Country list search/sort works; severity shown as icon + text |
| Story detail | Summary, sources, Ask VeriMundi (heuristic backend OK without GenAI key) |
| Report | Submit reason; success or typed failure snackbar (no false “thanks” on 401/offline) |
| Saved | Snapshot age notice present when viewing saved items |
| Maintenance drill (optional) | Flip `App__MaintenanceMode=true` on API → feeds show maintenance; `/health` + `/v1/app/config` still up |

---

## 6. What this runbook does **not** cover

- Approving RSS/GDELT/commercial sources (Tubo / legal)
- Production GenAI keys or cost controls
- Play signing / Android APK (see `android_sdk_blocker.md`)
- Notifications (§26 truncated — do not invent)
- GeoJSON choropleth assets

---

## 7. Result record (copy into issue / chat)

| Field | Value |
| --- | --- |
| Date (UTC) | |
| Operator | |
| `STAGING_API_BASE_URL` host only (no secrets) | |
| API `/health` `/ready` `/v1/app/config` | pass / fail |
| Flutter target (`chrome` / `linux` / device) | |
| `APP_ENV` | staging |
| Demo banner hidden | yes / no |
| Feeds / empty honesty | pass / fail |
| Ask / report | pass / fail |
| Ops ingestion tested | yes / no / n/a |
| Notes / follow-ups | |
