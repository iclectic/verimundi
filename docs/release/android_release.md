# Android Release Runbook

This runbook covers VeriMundi Android packaging for **demo (mock)** and **live (remote)** Play tracks.

## Environment blocker

Cloud Agent / default CI images without an Android SDK cannot produce APK/AAB artefacts.

- Probe: `./scripts/check_android_sdk.sh`
- Detail: `docs/release/android_sdk_blocker.md`
- CI policy: `docs/release/android_ci_notes.md`
- Signing: `docs/release/android_signing_checklist.md`

**This environment (2026-10-27):** `ANDROID_HOME` / `ANDROID_SDK_ROOT` unset; `flutter build apk` → *No Android SDK found*. APK/AAB **not** produced here.

## Release posture

| Track | Dart defines | Store honesty |
| --- | --- | --- |
| **Demo / internal** | `NEWS_API_BASE_URL=mock` | Fictional content; demo banner; no live-news claims |
| **Production / live** | `APP_ENV=production` + real `https://…` API | Remote feeds/Ask/reports; never silent mock (`AppDataMode.misconfigured` if mis-set) |

Still required before a **live** Play track (several are **EXTERNAL**):

- Rights-cleared sources + production ingestion flags (ops)
- Privacy / Data Safety **legal review**
- Upload keystore + Play Console account
- SDK-capable builder
- Staging API smoke against a real URL

## Network permission

Main manifest includes `INTERNET` so **release** remote builds can reach the API. Debug/profile manifests also declare it for tooling.

## Signing

See `docs/release/android_signing_checklist.md`. Release Gradle tasks require `android/key.properties` (gitignored).

## Versioning

Update `pubspec.yaml` before every Play upload (`version: name+code`). Never reuse or lower `versionCode`.

Current packaged identity:

- Application id: `com.iclectic.verimundi`
- Label: `VeriMundi`
- `pubspec.yaml` version: see repo (bump before upload)

## Build artefacts

```text
build/app/outputs/bundle/release/app-release.aab   # Play upload
build/app/outputs/flutter-apk/app-release.apk      # sideload / QA (optional)
```

Commands (SDK host only):

```bash
./scripts/check_android_sdk.sh

# Demo
flutter build appbundle \
  --dart-define=APP_ENV=development \
  --dart-define=NEWS_API_BASE_URL=mock

# Production candidate
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=NEWS_API_BASE_URL=https://api.example.com
```

## Release checks

- [ ] Signed with release config (not debug)
- [ ] Manifest label `VeriMundi`; package `com.iclectic.verimundi`
- [ ] Target SDK meets current Play requirement (Flutter `targetSdk`)
- [ ] Dart-defines match the intended track (production ≠ mock)
- [ ] Public privacy policy URL + Data Safety match binary (**legal EXTERNAL**)
- [ ] `flutter test` / `flutter analyze` / backend tests green
- [ ] Play pre-launch report reviewed on an SDK/device host
- [ ] Screenshots show honest demo vs live posture

## Local verification record

| Field | Value |
| --- | --- |
| Version |  |
| Build number |  |
| Commit |  |
| Track (demo / live) |  |
| `NEWS_API_BASE_URL` |  |
| Android devices tested |  |
| Tablet/foldable tested |  |
| Large text tested |  |
| Dark theme tested |  |
| Play pre-launch report reviewed |  |
| Data Safety / privacy legal review |  |
