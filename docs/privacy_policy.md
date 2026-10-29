# VeriMundi Privacy Policy

Effective date: 2026-10-27

**Status:** Engineering draft. **Legal review is an EXTERNAL BLOCKER** before public production or Play Store publication. Do not treat this text as counsel-approved.

This policy describes VeriMundi’s privacy posture for mock/demo builds and for builds that connect to a VeriMundi backend.

## Modes

- **Mock / demo mode** (`NEWS_API_BASE_URL=mock`): uses local fictional content only. Ask answers and problem reports are not sent to a server.
- **Remote mode**: the app requests story metadata from a VeriMundi API you configure. No news-provider or GenAI secrets are stored in the Flutter client.

## Data We Do Not Collect (current product)

VeriMundi does not create user accounts, collect names, collect email addresses, collect precise device location/GPS, collect contacts, use advertising IDs, or process payments in the current codebase.

## Data Stored on Your Device

When you save a story, VeriMundi stores a local snapshot on your device (story ID, headline, country code, summary, verification status, source count, saved time).

The app may also cache recent feed metadata locally so previously loaded stories remain available offline for a limited period. Cached feed entries are labelled by age (fresh / stale-but-usable / expired). When the network is unavailable the app may show a cached or even expired snapshot with an explicit offline warning — never as a live feed. Cache payloads contain VeriMundi story metadata and permitted excerpts only — not full copyrighted third-party article bodies.

Uninstalling the app removes local app data according to platform behaviour. Users can also remove individual saved stories in-app.

## Questions and reports (remote mode)

If remote mode is enabled:

- “Ask VeriMundi” questions for a story are sent to the VeriMundi backend with the story context needed to answer from linked sources.
- Optional problem reports (a fixed reason category + optional free-text details, max 500 characters) may be sent to the VeriMundi backend for editorial follow-up.
- The API applies per-IP rate limits on write endpoints, with stricter limits for Ask and reports, to reduce abuse. Client IP addresses are processed transiently for that purpose and are not used to build advertising profiles.

Questions and reports should not include personal data you do not wish to share. Free-text report details are not written to application logs (only length); reason categories may appear in operational logs for moderation routing. There is currently no durable public-facing moderation inbox — accepted reports are acknowledged (`202`) and logged for operators.

When optional OpenAI-compatible GenAI is enabled on the **host**, Ask/synthesis prompts derived from story evidence (and the user question for Ask) may be sent to that provider under the operator’s account. The Flutter client never holds GenAI keys. See `docs/ai_safety.md`.

## Demo content and AI labels

In mock mode, stories and answers are fictional demo content. In remote mode, AI-assisted summaries and answers are produced on the backend from linked source evidence and remain labelled, with uncertainty shown when evidence is insufficient.

## Network and third-party SDKs

Mock builds do not require a live backend. Remote builds contact only the configured VeriMundi API base URL over HTTPS in production configurations. If crash reporting, analytics, or additional SDKs are added later, this policy and Google Play Data Safety answers must be updated **and** re-reviewed before release.

## Children

VeriMundi is not directed to children. Play Console audience declarations must match the final listing and content rating.

## Contact

Add the production privacy contact email before publishing this policy publicly.

## Legal review (EXTERNAL)

| Item | Status |
| --- | --- |
| Engineering draft of this policy | Present |
| Play Data Safety worksheet alignment | Present (`docs/play_data_safety.md`) |
| Counsel / privacy officer sign-off | **BLOCKED EXTERNALLY** — required before store submission |
| Production privacy contact email | **BLOCKED EXTERNALLY** — operator must supply |

This document is an engineering draft. It is **BLOCKED EXTERNALLY** pending legal review before production store submission.
