# VeriMundi

**The world beyond the usual headlines**

VeriMundi is a Flutter MVP for global news discovery focused on important stories from countries and regions that are often underrepresented in major international feeds. This build uses fictional local mock data only.

## Features

- World dashboard with severity-aware country markers.
- Global, underreported, positive, and saved story feeds.
- Story detail pages with AI-labeled summaries, facts, uncertainty, coverage comparison, source lists, and mock story questions.
- Transparent underreported scoring based on importance, local coverage, and international coverage gap.
- Drift-backed saved story snapshots.
- Material 3 light and dark themes.

## MVP Status

This is an initial working MVP. It does not connect to live news, live AI providers, or user accounts. All story content is fictional and marked as demo content.

## Screenshots

Screenshots will be added after the first design QA pass:

- World dashboard
- Underreported feed
- Positive World feed
- Story detail
- Saved stories

## Architecture

The app uses a feature-first clean architecture:

- `app/`: bootstrap, app shell, navigation.
- `core/`: constants, theme, database, network, utilities.
- `features/`: world, stories, underreported, positive news, saved stories, settings, story questions.
- `shared/`: immutable models, providers, reusable widgets.
- `assets/mock/`: fictional MVP catalog.
- `docs/`: product, API, and AI safety notes.

Riverpod handles dependency injection and state. `go_router` handles navigation. Freezed and JSON serialization define immutable models. Drift persists saved story snapshots. Dio is present for the future backend client.

## Local Setup

```bash
flutter pub get
dart run build_runner build
dart format .
flutter analyze
flutter test
flutter run
```

To point a future build at a backend:

```bash
flutter run --dart-define=NEWS_API_BASE_URL=https://api.example.com
```

The safe default is `mock`, which keeps the app in local demo mode.

## Mock Data

The catalog in `assets/mock/verimundi_mock_catalog.json` includes 20 countries across all supported regions and 30 fictional story seeds. The repository expands those seeds into story clusters with multiple source articles. No fictional story uses real deaths, active wars, real named suspects, or real allegations against identifiable people.

## AI Safety Principles

The Flutter client must never call a commercial GenAI provider with a secret key. Future AI operations should run through a secure backend and summarize only supplied source material. Confirmed facts must reference source IDs, uncertainty must remain visible, and insufficient evidence must be shown plainly.

## Roadmap

- Real multilingual news ingestion.
- RSS and licensed news provider integrations.
- Article clustering and deduplication.
- Local-language translation.
- Country-polygon choropleth map.
- Transparent source credibility methodology.
- User accounts and synchronized bookmarks.
- Story update notifications.

## Licence

Licence to be decided before public distribution.
