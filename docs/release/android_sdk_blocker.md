# Android SDK / APK build blocker (Phase 14)

## Status

**BLOCKED EXTERNALLY** in the current Cloud Agent / default CI environment.

Re-probed: **2026-10-27** on `cursor/verimundi-live-news-sources-b049`.

## Observed failure

```text
$ echo ANDROID_HOME=${ANDROID_HOME:-unset}
ANDROID_HOME=unset

$ ./scripts/check_android_sdk.sh
BLOCKED: ANDROID_HOME / ANDROID_SDK_ROOT not set.

$ flutter build apk --debug -t lib/main.dart
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

## Impact

- Signed/release APK or AAB verification **cannot** be completed here.
- Phase 14 Play production packaging remains blocked until an Android SDK (and release keystore via local `android/key.properties`) is available on a build host.
- CI intentionally does not attempt APK builds — see `docs/release/android_ci_notes.md`.

## Required to unblock

1. Install Android SDK / set `ANDROID_HOME` (accept licences).
2. Provide release signing material locally (never commit secrets) — `docs/release/android_signing_checklist.md`.
3. Build with track-appropriate dart-defines (`docs/release/android_release.md`).

```bash
./scripts/check_android_sdk.sh
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=NEWS_API_BASE_URL=https://api.example.com
```

## Local probe script

```bash
chmod +x scripts/check_android_sdk.sh
./scripts/check_android_sdk.sh
```

Exit `0` when a usable Android toolchain is detected; exit `1` when blocked.

## What remains ready without SDK

- Flutter analyze/test suite + backend build/test
- Release / signing / CI / Play Console docs under `docs/release/`
- Main manifest `INTERNET` permission for future remote release builds
- Data Safety / privacy drafts (legal review still **EXTERNAL**)
- Staging API curl smoke (`scripts/staging_api_smoke.sh`) when a URL exists
