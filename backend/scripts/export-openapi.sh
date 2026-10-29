#!/usr/bin/env bash
# Regenerate backend/contracts/openapi.v1.json after intentional API contract changes.
# Commit the updated snapshot; CI fails on unintended OpenAPI diffs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export UPDATE_OPENAPI_SNAPSHOT=1
dotnet test tests/VeriMundi.IntegrationTests \
  --filter "FullyQualifiedName~OpenApiContractTests.Snapshot_matches_committed_openapi" \
  --verbosity minimal
echo "Wrote contracts/openapi.v1.json"
