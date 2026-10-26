#!/usr/bin/env bash
# Curl-only staging API smoke checks. No secrets are hard-coded.
# Usage:
#   export STAGING_API_BASE_URL='https://api.staging.example'  # no trailing slash
#   ./scripts/staging_api_smoke.sh
# Optional:
#   export Ops__AdminIngestionToken='…'   # if set, also probes admin auth (401 without token already covered)
set -euo pipefail

if [[ -z "${STAGING_API_BASE_URL:-}" ]]; then
  echo "Set STAGING_API_BASE_URL (no trailing slash), e.g. https://api.staging.example" >&2
  echo "See docs/release/staging_flutter_api_smoke.md" >&2
  exit 2
fi

BASE="${STAGING_API_BASE_URL%/}"
failed=0

check() {
  local name="$1"
  local url="$2"
  local code
  code=$(curl -sS -o /tmp/verimundi-smoke-body.json -w '%{http_code}' "$url" || true)
  if [[ "$code" != "200" ]]; then
    echo "FAIL $name → HTTP $code ($url)"
    failed=1
    return
  fi
  echo "OK   $name → HTTP $code"
}

echo "VeriMundi staging API smoke"
echo "Base: $BASE"
echo "---------------------------"

check "GET /health" "$BASE/health"
check "GET /ready" "$BASE/ready"
check "GET /v1/app/config" "$BASE/v1/app/config"
check "GET /v1/world/status" "$BASE/v1/world/status"
check "GET /v1/stories" "$BASE/v1/stories?page=1&pageSize=5"

# Admin without token: expect 401 when Ops token is configured on the host;
# Development with empty token may return non-401 (document in runbook).
admin_code=$(curl -sS -o /tmp/verimundi-smoke-admin.json -w '%{http_code}' \
  -X POST "$BASE/v1/admin/ingestion/run" || true)
echo "INFO POST /v1/admin/ingestion/run (no token) → HTTP $admin_code"
if [[ -n "${Ops__AdminIngestionToken:-}" ]]; then
  auth_code=$(curl -sS -o /tmp/verimundi-smoke-admin-auth.json -w '%{http_code}' \
    -X POST "$BASE/v1/admin/ingestion/run" \
    -H "X-VeriMundi-Ops-Token: ${Ops__AdminIngestionToken}" || true)
  echo "INFO POST /v1/admin/ingestion/run (with token) → HTTP $auth_code"
  if [[ "$auth_code" == "401" ]]; then
    echo "FAIL admin call still unauthorized with provided token"
    failed=1
  fi
fi

if [[ "$failed" -ne 0 ]]; then
  echo "Smoke failed. Inspect /tmp/verimundi-smoke-*.json and docs/release/staging_flutter_api_smoke.md"
  exit 1
fi

echo "Smoke passed (read paths). Continue with Flutter steps in the runbook."
exit 0
