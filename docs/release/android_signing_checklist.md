# Android signing checklist

**Secrets never belong in git.** `android/key.properties`, `*.jks`, and `*.keystore` are gitignored.

## Prerequisites

- [ ] Play Console app created (`com.iclectic.verimundi`)
- [ ] Play App Signing accepted
- [ ] Upload keystore generated and backed up offline by the release owner
- [ ] `android/key.properties` present **only** on the build host (not committed)

## `android/key.properties` template

```properties
storePassword=<local secret>
keyPassword=<local secret>
keyAlias=upload
storeFile=<absolute-or-relative path to upload-keystore.jks>
```

Gradle refuses release tasks when this file is missing (`android/app/build.gradle.kts`).

## Build host checks

- [ ] `./scripts/check_android_sdk.sh` exits 0
- [ ] `keytool -list -keystore <storeFile>` succeeds with the upload alias
- [ ] Release build uses the `release` signing config (not debug)

## Demo vs production dart-defines

| Track | `APP_ENV` | `NEWS_API_BASE_URL` |
| --- | --- | --- |
| Internal demo | `development` or `staging` | `mock` |
| Live candidate | `production` | `https://…` VeriMundi API (never `mock`) |

```bash
# Demo AAB (local SDK required)
flutter build appbundle \
  --dart-define=APP_ENV=development \
  --dart-define=NEWS_API_BASE_URL=mock

# Production AAB (local SDK + key.properties + live API)
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=NEWS_API_BASE_URL=https://api.example.com
```

## Version bump before every Play upload

- Edit `pubspec.yaml` `version: x.y.z+build`
- `versionName` = `x.y.z`; `versionCode` = integer after `+`
- Never reuse or decrease `versionCode`

## After build

- [ ] Artifact: `build/app/outputs/bundle/release/app-release.aab`
- [ ] Upload to **internal testing** first
- [ ] Confirm Data Safety + privacy URL match this binary (`docs/play_data_safety.md`, `docs/privacy_policy.md` — legal review still **EXTERNAL**)
