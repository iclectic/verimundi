# VeriMundi agent rules

Concise operating rules for humans and coding agents working in this repository.

1. **Preserve working functionality.** Prefer incremental changes over rewrites. Do not replace the Flutter feature architecture without cause.
2. **No secrets in the Flutter client.** News-provider credentials and GenAI keys belong only on the backend (env / secret store).
3. **Never commit production API keys**, keystores, or `key.properties` with real passwords.
4. **Never scrape or reproduce third-party article bodies** without verified permission. Prefer metadata, headlines, links, and permitted excerpts.
5. **Source attribution is mandatory** for every displayed article and confirmed fact.
6. **AI-generated claims must remain grounded** in supplied source material. No model-memory “current facts”.
7. **Unknown information must remain unknown.** Use insufficient-evidence paths instead of guessing.
8. **Prefer deterministic algorithms** for scoring, clustering signals, and ranking where deterministic methods are appropriate.
9. **Use GenAI for synthesis**, not as a substitute for source evidence.
10. **Every significant feature requires tests.** Do not delete tests merely to obtain a passing build.
11. **Run formatting, analysis, and relevant tests** after significant work (`dart format`, `flutter analyze`, `flutter test`; backend `dotnet test` when touching `backend/`).
12. **Use British English** in VeriMundi-owned product copy.
13. **Avoid sensational language.**
14. **Do not hide uncertainty.** Surfaces must show confidence, disputes, and gaps.
15. **Do not silently replace working architecture** (Riverpod, GoRouter, Drift, Freezed, mock fixtures).
16. **Do not commit or push unless explicitly authorised** by the user.
17. **Keep changes small enough to understand and review.**
18. **Update documentation** whenever architecture or product behaviour materially changes.
19. **Production builds must never silently fall back to fictional/mock news.** Mock mode remains available for development, tests, screenshots, and demos only when explicitly selected.
20. **Respect the source registry.** Only `approved` sources may power live production feeds.

## Default local modes

- Flutter mock (safe default): `NEWS_API_BASE_URL=mock` (or omit the define).
- Flutter remote: `--dart-define=NEWS_API_BASE_URL=http://localhost:5080` (or staging/production URL) plus `--dart-define=APP_ENV=development|staging|production`.
- Backend: see `backend/README.md` and `docs/architecture/backend_decision.md`.

## Product honesty

VeriMundi broadens regional and source visibility. Story selection, classification, and AI-generated summaries remain imperfect and should be considered alongside the original reporting.
