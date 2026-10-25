# VeriMundi engineering evidence (portfolio)

Honest changelog from mock MVP → production-oriented vertical slice (Phases 0–15 scaffolding).

## Product claim

VeriMundi broadens regional and source visibility. Selection, classification, and AI-assisted summaries remain imperfect and should be read alongside original reporting.

## What shipped in this completion arc

| Layer | Evidence |
| --- | --- |
| Flutter MVP preserved | Riverpod, GoRouter, Drift, Freezed, Material 3 feeds |
| Backend modular monolith | `backend/` ASP.NET Core 8 + PostgreSQL + `/v1` OpenAPI |
| Ingestion | Approved fixture sources; RSS provider gated; registry docs |
| Clustering / scoring | URL/hash dedupe, independent counts, World Pulse regional balance |
| AI | Backend `IAiSynthesisService` heuristic path (no client secrets) |
| Flutter remote | `RemoteNewsRepository`, `APP_ENV`, no silent production mock |
| Map | Severity legend + icons, list alternative, region filters, zoom/pan |
| Discovery | Debounced search, richer filters, active chips, empty state, paging UI |
| Offline | Feed metadata cache with fresh/stale/expired labels |
| Safety | Reports endpoint, rate limit middleware, privacy/Data Safety drafts |
| CI | Flutter workflow + backend workflow |

## Screenshots / demos

Screenshots and device recordings should be captured on a machine with Android/iOS tooling. This environment cannot produce APK demos (see `docs/release/android_sdk_blocker.md`).

Suggested capture list:

1. World map + country list alternative  
2. Underreported feed with reason copy  
3. Story detail (facts, timeline, Ask, report)  
4. Saved snapshot age notice  
5. Settings data-mode disclosure  

## Methodology docs

- `docs/methodology/world_pulse_ranking.md`
- `docs/methodology/underreported_methodology.md`
- `docs/sources/source_registry.md`
- `docs/architecture/backend_decision.md`

## Explicit non-claims

- Not yet a rights-cleared commercial news product  
- Not yet production GenAI (heuristic synthesis default)  
- Notifications not specified (truncated brief §26)  
- Android production bundle not verified in this environment  
