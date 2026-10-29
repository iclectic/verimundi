# VeriMundi Play Store Listing Draft

Adjust copy for the **track** you upload. Do not mix demo claims with a live binary (or the reverse).

## App Name

VeriMundi

## Short Description

**Demo track:** Explore a fictional demo of global news discovery beyond the usual headlines.  
**Live track:** Explore global story clusters with transparent source coverage, uncertainty, and grounded Ask answers.

## Full Description — demo track (`NEWS_API_BASE_URL=mock`)

VeriMundi is a demo MVP for exploring a broader, more transparent way to scan global developments. It highlights fictional story examples from countries and regions that are often underrepresented in major international feeds.

This release uses demo content only. Stories, sources, source counts, AI summaries, and AI answers are fictional and are provided for product evaluation. VeriMundi does not currently provide live news, breaking-news alerts, real source retrieval, user accounts, or GenAI provider calls from the device.

Current demo features:

- World dashboard with severity-aware map (colour, hatch, and icons — not colour alone) and an accessible country list.
- World Pulse, Underreported, Positive World, and Saved story views.
- Story detail with AI-labelled summaries, confirmed facts, uncertainties, coverage comparison, timeline, ranking reasons, and report actions.
- Transparent demo labels across the app.
- Local saved-story snapshots and short-lived feed metadata cache on the device.
- Light and dark Material 3 themes.

## Full Description — live track (`APP_ENV=production` + HTTPS API)

VeriMundi surfaces story clusters with local/regional/international coverage signals, uncertainty, and corrections when material facts change. Summaries and Ask VeriMundi answers are produced by the VeriMundi backend from linked source evidence and remain labelled; the app never stores commercial GenAI API keys.

This build connects to a VeriMundi API you operate. It does not create user accounts or send push notifications in the current product. Optional Ask questions and problem reports may be sent to the API (rate-limited). Saved stories and feed metadata may be cached on device and are labelled when offline — never presented as a live feed when stale.

Do not claim complete objectivity, breaking-news alerts, or that every region is fully covered.

## Screenshot Checklist

- World dashboard (demo banner visible on mock builds).
- Underreported feed.
- Positive World feed.
- Story detail with summary, uncertainties, sources, timeline / ranking when present.
- Saved stories (empty + one saved).
- Settings: release status, data mode, AI transparency, privacy.

## Review Notes

- Package: `com.iclectic.verimundi`
- No ads, no in-app purchases, no accounts in the current codebase.
- Client never holds GenAI secrets.
- Privacy / Data Safety answers must match the uploaded binary; legal review is **EXTERNAL** before public production.

## Support Contact

Add the production support email in Play Console before submission.
