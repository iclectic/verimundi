# VeriMundi Privacy Policy

Effective date: 2026-10-24

This policy describes VeriMundi’s current privacy posture for mock/demo builds and for builds that connect to a VeriMundi backend. Legal review is required before public production publication.

## Modes

- **Mock / demo mode** (`NEWS_API_BASE_URL=mock`): uses local fictional content only.
- **Remote mode**: the app requests story metadata from a VeriMundi API you configure. No news-provider or GenAI secrets are stored in the Flutter client.

## Data We Do Not Collect (current product)

VeriMundi does not create user accounts, collect names, collect email addresses, collect precise location, collect contacts, use advertising IDs, or process payments in the current codebase.

## Data Stored on Your Device

When you save a story, VeriMundi stores a local snapshot on your device (story ID, headline, country code, summary, verification status, source count, saved time).

The app may also cache recent feed metadata locally so previously loaded stories remain available offline for a limited period. Cached feed entries are labelled by age (fresh / stale-but-usable / expired) and are never presented as live when stale. Cache payloads contain VeriMundi story metadata and permitted excerpts only — not full copyrighted third-party article bodies.

Uninstalling the app removes local app data according to platform behaviour.

## Questions and reports (remote mode)

If remote mode is enabled:

- “Ask VeriMundi” questions for a story are sent to the VeriMundi backend with the story context needed to answer from linked sources.
- Optional problem reports (reason + optional free-text details) may be sent to the VeriMundi backend for editorial follow-up.

Questions and reports should not include personal data you do not wish to share.

## Demo content and AI labels

In mock mode, stories and answers are fictional demo content. In remote mode, AI-assisted summaries and answers are produced on the backend from linked source evidence and remain labelled, with uncertainty shown when evidence is insufficient.

The Flutter client never stores commercial GenAI API keys.

## Network and third-party SDKs

Mock builds do not require a live backend. Remote builds contact only the configured VeriMundi API base URL. If crash reporting or analytics are added later, this policy and Google Play Data Safety answers must be updated before release.

## Children

VeriMundi is not directed to children. Play Console audience declarations must match the final listing and content rating.

## Contact

Add the production privacy contact email before publishing this policy publicly.

## Legal review

This document is an engineering draft. It is **BLOCKED EXTERNALLY** pending legal review before production store submission.
