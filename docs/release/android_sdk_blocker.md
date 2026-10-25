# Android SDK / APK build blocker (Phase 14)

## Status

**BLOCKED EXTERNALLY** in the current Cloud Agent environment.

## Observed failure

```text
flutter build apk --debug
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

Exit code: 1

## Impact

- Signed/release APK verification cannot be completed in this environment.
- Phase 14 Play production packaging remains blocked until an Android SDK (and release keystore via local `android/key.properties`) is available.

## Required to unblock

1. Install Android SDK / set `ANDROID_HOME` (and accept licences).
2. Provide release signing material locally (never commit secrets).
3. Build with a non-mock production configuration only after remote API readiness:

```bash
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=NEWS_API_BASE_URL=https://api.example.com
```

## What remains ready without SDK

- Flutter analyze/test suite
- Backend build/test
- Release runbooks under `docs/release/`
- Data Safety / privacy drafts for legal review
