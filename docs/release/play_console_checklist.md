# Play Console Checklist

Use this checklist for VeriMundi Android submission. Choose **demo** or **live** track honesty before upload.

## App Setup

- [ ] Create the app in Play Console as an app, not a game.
- [ ] Use `VeriMundi` as the store display name.
- [ ] Confirm the package name is `com.iclectic.verimundi`.
- [ ] Add the production support email (**EXTERNAL** — operator supplies).
- [ ] Accept Play App Signing.
- [ ] Add the public privacy policy URL (text is an engineering draft until **legal review EXTERNAL**).

## Track selection

| Track | Binary dart-defines | Listing language |
| --- | --- | --- |
| Demo / closed evaluation | `NEWS_API_BASE_URL=mock` | Emphasise fictional demo content |
| Live production candidate | `APP_ENV=production` + real HTTPS API | Remote feeds; no silent mock; update Data Safety for Ask/reports |

Do **not** upload a production-labelled listing that ships mock news, or a demo listing that implies live coverage.

## Store Listing

- [ ] Start from `docs/play_store_listing.md` and adjust for the chosen track.
- [ ] Upload screenshots for World, Underreported, Positive World, Story Detail, Saved, and Settings.
- [ ] Keep demo content labels visible when shipping mock; keep offline/cache honesty visible for live.
- [ ] Do not claim breaking-news alerts, accounts, ads, or client-side GenAI secrets.
- [ ] Feature graphic: no small unreadable text or misleading non-Android device imagery.

## Policy Declarations

- [ ] Complete Data Safety from `docs/play_data_safety.md` for the **exact** binary (mock vs remote UGC differs).
- [ ] Complete target audience and content rating.
- [ ] Declare ads / IAP honestly (current product: none).
- [ ] Remote builds: Ask questions + optional reports are user-generated content sent to the VeriMundi API — declare accordingly.
- [ ] Re-check if any SDK, permission, backend, telemetry, or account behaviour changes.
- [ ] Counsel sign-off on privacy + Data Safety (**EXTERNAL**).

## Testing Tracks

- [ ] Upload the signed app bundle to **internal testing** first (SDK host + signing checklist).
- [ ] Review install, launch, navigation, saved stories, settings, story detail, report, and Ask on at least one physical Android device.
- [ ] Review the Play pre-launch report and fix blocker warnings.
- [ ] Personal developer accounts: closed testing with ≥12 opted-in testers for 14 continuous days before production access (current Play rules — verify on Console).
- [ ] Keep a summary of tester feedback for the production-access questionnaire.

## Production Rollout

- [ ] Submit only after policy declarations, privacy policy, release evidence, and pre-launch report are complete.
- [ ] Use staged rollout for the first production release.
- [ ] Monitor crashes, Android vitals, reviews, and support email after rollout.
- [ ] Halt or pause rollout if users report misleading content, launch crashes, saved-story data loss, or major accessibility failures.

## Blockers that stay EXTERNAL from this agent environment

- Android SDK / AAB production in Cloud Agent CI (`docs/release/android_sdk_blocker.md`)
- Play Console account + upload keystore
- Privacy legal review + production contact email
- Staging API base URL for end-to-end device smoke
