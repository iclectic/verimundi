# VeriMundi

**The world beyond the usual headlines**

VeriMundi is a global news-discovery application intended to help users find important, underreported, and constructive developments beyond popularity-driven international feeds.

This repository contains:

- A Flutter client (Material 3, Riverpod, GoRouter, Drift) with **mock** and **remote** modes
- An ASP.NET Core + PostgreSQL modular monolith under `backend/`

## Modes

| Mode | How | Notes |
| --- | --- | --- |
| Mock (default) | `NEWS_API_BASE_URL=mock` or omit | Fictional catalog; safe for demos/tests |
| Remote | `--dart-define=NEWS_API_BASE_URL=http://localhost:5080 --dart-define=APP_ENV=development` | Talks to `/v1` API |
| Production | `APP_ENV=production` + real API URL | **Must not** use mock; misconfiguration fails loudly |

## Local setup (Flutter)

```bash
flutter pub get
dart run build_runner build
dart format .
flutter analyze
flutter test
flutter run
```

## Local setup (backend)

See `backend/README.md` and `docs/architecture/backend_decision.md`.

```bash
cd backend
dotnet run --project src/VeriMundi.Api --urls http://0.0.0.0:5080
```

## Documentation

- `docs/completion/current_state_audit.md`
- `docs/completion/master_completion_plan.md`
- `AGENTS.md`
- `docs/sources/source_registry.md`
- `docs/methodology/*`
- `docs/api_contract.md`

## Architecture (Flutter)

- `app/`: bootstrap, shell, navigation
- `core/`: constants, theme, database, network
- `features/`: world, stories, underreported, positive, saved, settings, story questions
- `shared/`: models, providers, widgets
- `assets/mock/`: fictional MVP catalog

## AI safety

The Flutter client must never call a commercial GenAI provider with a secret key. Synthesis and grounded Q&A run on the backend from supplied evidence only.

## Licence

Licence to be decided before public distribution.
