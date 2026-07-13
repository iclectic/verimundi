# Android Release Runbook

This runbook covers the VeriMundi Android demo MVP release.

## Release Posture

The current Play Store release target is a production-quality demo MVP. It uses local fictional content and should be built with `NEWS_API_BASE_URL=mock`.

Do not submit a non-mock release until `RemoteNewsRepository` is implemented, policy docs are updated, and live backend behavior is tested.

## Signing

Release builds require `android/key.properties`, which must not be committed.

Expected keys:

```properties
storePassword=<local secret>
keyPassword=<local secret>
keyAlias=upload
storeFile=<path to local upload keystore>
```

The upload keystore should be owned by the release owner and backed up according to your operational policy. Use Google Play App Signing for production distribution.

## Versioning

Update `pubspec.yaml` before every Play upload. `versionName` comes from the version before `+`; `versionCode` comes from the integer after `+`.

Never upload a bundle with a reused or lower versionCode.

## Build Artifact

The Play artifact is the Android App Bundle generated at:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Release Checks

- The release build is signed with the release signing config, not the debug key.
- `android/app/src/main/AndroidManifest.xml` displays `VeriMundi`.
- Target SDK meets the current Google Play requirement.
- `NEWS_API_BASE_URL` is `mock` for the demo MVP.
- `docs/privacy_policy.md` has a public URL.
- `docs/play_data_safety.md` matches the binary and dependencies.
- Tests, analysis, and integration journey checks pass.
- Play pre-launch report has no unresolved blocker.

## Local Verification Record

Record each release candidate:

| Field | Value |
|---|---|
| Version |  |
| Build number |  |
| Commit |  |
| Android devices tested |  |
| Tablet/foldable tested |  |
| Large text tested |  |
| Dark theme tested |  |
| Play pre-launch report reviewed |  |
| Data Safety reviewed |  |

