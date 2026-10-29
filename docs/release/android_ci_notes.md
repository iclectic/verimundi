# Android CI notes (Phase 14)

## Current CI (this repo)

| Workflow | Builds APK/AAB? | Why |
| --- | --- | --- |
| `.github/workflows/flutter.yml` | **No** | Runs `format` / `analyze` / `flutter test` on `ubuntu-latest` without Android SDK |
| `.github/workflows/backend.yml` | N/A | .NET only |

Cloud Agent / default GitHub-hosted images used here also lack `ANDROID_HOME` — confirmed by `scripts/check_android_sdk.sh` and `flutter build apk` → *No Android SDK found*.

## What CI should keep doing

1. Flutter analyze + full test suite (honesty, a11y, remote mapping)
2. Backend unit + integration tests
3. Format gates

These do **not** require an Android SDK and must stay green before any Play upload.

## Optional future job (when a runner has an SDK)

Do **not** enable until:

- A self-hosted or specialised runner with Android SDK + licences is available, **or**
- A maintained GitHub Action image with SDK is explicitly chosen and licensed
- Release signing secrets are injected via GitHub Actions secrets / OIDC — never plaintext in YAML

Suggested shape (illustrative — not enabled in this repo yet):

```yaml
# Optional job — requires ANDROID_HOME on the runner + secrets.
# android-release:
#   runs-on: [self-hosted, android-sdk]
#   steps:
#     - uses: actions/checkout@v4
#     - uses: subosito/flutter-action@v2
#     - run: ./scripts/check_android_sdk.sh
#     - run: |
#         flutter build appbundle \
#           --dart-define=APP_ENV=production \
#           --dart-define=NEWS_API_BASE_URL=${{ secrets.NEWS_API_BASE_URL }}
#       env:
#         # Write key.properties from secrets in a prior step; never echo passwords.
```

## Local / release-owner path (required today)

1. Machine with Android SDK → `./scripts/check_android_sdk.sh`
2. Follow `docs/release/android_signing_checklist.md`
3. Follow `docs/release/android_release.md` + `docs/release/play_console_checklist.md`

## Honest status line for portfolios

> Android package verification is blocked in CI/Cloud Agent images without an Android SDK. Release AABs must be produced on an SDK-equipped host with local signing material.
