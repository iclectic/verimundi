# Google Play Data Safety Worksheet

Use this worksheet to complete Google Play Data Safety for the current Android demo release. Re-check it whenever permissions, SDKs, backend behavior, or telemetry changes.

## Current Release Summary

- **Release mode:** Demo MVP with fictional local content.
- **Accounts:** None.
- **Ads:** None.
- **In-app purchases:** None.
- **Push notifications:** None.
- **Live backend:** Not enabled.
- **Commercial GenAI provider calls from client:** None.
- **Crash/analytics SDKs:** None at initial release.
- **Local storage:** Saved-story snapshots stored in the app's local Drift/SQLite database.

## App Data Inventory

| Data category | Collected off device? | Shared? | Purpose | Notes |
|---|---:|---:|---|---|
| Account identifiers | No | No | Not applicable | No sign-in or account creation exists. |
| Contact information | No | No | Not applicable | No email, phone, or address collection exists. |
| Location | No | No | Not applicable | Country coordinates are fictional catalog metadata, not user location. |
| App activity | No | No | Not applicable | No analytics SDK is enabled. |
| App diagnostics | No | No | Not applicable | Update this if crash reporting is added. |
| User-generated content | No | No | Not applicable | Story questions are processed by the mock service locally. |
| Files and docs | No | No | Not applicable | No file upload or external sharing exists. |
| Local saved stories | No | No | App functionality | Stored only on device in app-private storage. |

## Permissions and Sensitive APIs

- `android/app/src/main/AndroidManifest.xml` declares no dangerous runtime permissions for the current release.
- The Flutter text-processing query block is generated for platform text integration and does not collect user data by itself.
- No background location, contacts, camera, microphone, SMS, calendar, or notification permissions are used.

## Third-Party Packages to Recheck

- Flutter SDK and Material components.
- `flutter_riverpod` for state management.
- `go_router` for navigation.
- `dio` for future networking; no live endpoint is enabled in demo mode.
- `drift`, `sqlite3`, `sqlite3_flutter_libs`, `path_provider`, and `path` for local persistence.
- `freezed_annotation`, `json_annotation`, and code generation packages for models.
- `flutter_svg`, `intl`, and `cupertino_icons` for UI support.

## Release Gate

Before submitting to Google Play:

1. Confirm the release build uses `NEWS_API_BASE_URL=mock` unless a real backend client and updated disclosures are complete.
2. Confirm no analytics, crash reporting, ads, payments, or account SDKs were added without updating this worksheet.
3. Confirm the public privacy policy URL matches `docs/privacy_policy.md`.
4. Complete Play Console Data Safety from this worksheet and store a dated copy of the submitted answers.

