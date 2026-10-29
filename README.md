# VeriMundi

I built VeriMundi because the international feeds I usually see feel narrow.

They reward volume and familiarity. The same countries, the same story shapes, the same urgency theatre. Meanwhile a local desk can be covering something that matters long before it shows up on a global homepage — and “positive” news, when it appears at all, often gets flattened into inspiration without the caveats that keep it honest.

So this is my attempt at a different kind of news surface: one that broadens regional and source visibility, separates severity from tone, and refuses to hide uncertainty behind a tidy AI paragraph.

It is not finished as a commercial live-news product. It is a working Flutter client and ASP.NET backend that already encode the honesty rules I care about — and that I can run end-to-end locally without pretending rights clearances I do not have.

## What it is

VeriMundi is a global news-discovery app. World Pulse, Underreported, and Positive World are three views over the same underlying story clusters. You scan a map or a feed, open a story, compare sources, read confirmed facts and uncertainties, ask a grounded question, save a snapshot for later.

Importance is not the same as popularity. Positive does not mean solved. Underreported scores are discovery aids, not claims that “the media is ignoring this.” Those lines are in the product copy on purpose.

Default local mode is **mock**: a fictional catalog under `assets/mock/`. That is intentional. Demo and test builds stay on fiction unless I point the client at a real API. Production builds that still say `NEWS_API_BASE_URL=mock` fail loudly. Silent fictional fallback in production is a hard forbid in this repo.

## Why this shape

I wanted something I could actually maintain alone without giving up production habits.

The client is Flutter — Material 3, Riverpod, GoRouter, Drift, Freezed. Feature folders under `lib/features/` (world, stories, underreported, positive, saved, settings, story questions). I kept that architecture deliberately; the point of the completion work was to grow a live path under it, not rewrite the shell.

The server is an ASP.NET Core 8 modular monolith with PostgreSQL: Api, Application, Domain, Infrastructure, Workers in one solution under `backend/`. One deployable host, in-process ingestion workers, OpenAPI in Development. Secrets live in env / user-secrets / the host secret store — never in Flutter `--dart-define`.

I chose that over microservices because the scoring, clustering, and AI contracts need strong typing and tests more than they need process boundaries right now. Modules can split later if ops pressure demands it.

## Honesty invariants

These are engineering rules, not slogans. They live in `AGENTS.md` and show up as real guards in code.

No news-provider or GenAI keys in the Flutter client. Source attribution on every article and confirmed fact. AI claims grounded in supplied evidence only — no model-memory “current facts.” Unknown stays unknown; insufficient-evidence paths exist for a reason. Deterministic scoring and clustering where that is the right tool; GenAI for synthesis, not as a substitute for evidence. Only `approved` sources may power live production feeds. British English in product copy. Uncertainty, disputes, and gaps stay visible.

If a build is mock, it says so. If a cache is stale or expired, the UI does not present it as a live feed. If production is misconfigured toward fiction, the app refuses to start that way.

## Sources

Live ingestion is gated by a source registry (`docs/sources/source_registry.md`) with statuses: proposed, approved, restricted, rejected. Unknown domains discovered at ingest time become proposed and stay disabled until reviewed.

What I have approved so far, based on posted terms (not counsel sign-off):

- **VeriMundi fixtures** — synthetic desks for local/dev; fine for demos if I disclose fixture mode.
- **UN News RSS** (`news.un.org`) — approved and enabled in seed. Headlines and short RSS summaries with attribution and link-back. No photos/AV without separate clearance. If I ever flip production RSS on, I still need to advise the UN (`unnews@un.org`).
- **GDELT DOC 2.0** — approved as **MetadataOnly** discovery. Useful for URLs and fields; it does not licence publisher headlines, bodies, or images. Each publisher domain still has to clear the registry before article ingest.

What stays restricted on purpose:

- **ReliefWeb** — personal non-commercial terms; product aggregation needs written OCHA/ReliefWeb clearance I do not have.
- **WHO newsroom** — commercial use needs prior written WHO authorisation.

I would rather leave those dark than invent clearance. Production base config keeps `Ingestion:EnableRss` and `Ingestion:EnableGdelt` **false** until ops explicitly opts in. Development and docker-compose turn them on locally so the live path is exercisable against approved rows only.

I do not scrape full copyrighted article bodies without a verified licence. Metadata, headlines, links, and permitted excerpts are the default posture.

## Map, offline, Ask

The world map is a Natural Earth public-domain 110m choropleth (`assets/geo/`, licence documented). Severity uses fill, hatch, and icons — colour alone is not the signal. There is a searchable country list alternative for accessibility, plus a country detail panel.

Offline behaviour sits on Drift. Feed envelopes cache with fresh / stale / expired semantics. Expired rows can still open offline with explicit “not a live feed” labelling. Saved stories are local snapshots; the UI says so.

Ask VeriMundi and story synthesis run on the backend through `IAiSynthesisService`. The default implementation is a deterministic **heuristic** synthesizer — no API key required, grounded JSON, insufficient-evidence and source-linked facts enforced. An optional OpenAI-compatible provider can plug in behind the same interface when `Ai:ApiKey` / `OPENAI_API_KEY` is set on the host. Flutter never holds that key. Ask and report paths are rate-limited; production GenAI spend caps are still an ops concern I have not wired as a product feature.

## Ops and observability

Local stack: `docker-compose.yml` brings up Postgres and the API. Health and readiness are separate (`/health`, `/ready`). `GET /v1/app/config` exposes maintenance mode, minimum app version, ingestion flags, and which AI provider is active.

Admin ingestion (`POST /v1/admin/ingestion/run`, metrics) is ops-token gated. Empty token is allowed only in Development/Testing; elsewhere it fails closed. Ingestion and API meters can scrape via optional Prometheus (`Telemetry:EnablePrometheus`). Rate limiting is pluggable — memory for Dev/Testing, Redis for multi-replica staging/production — and still not a substitute for edge/WAF controls.

Staging smoke is documented in `docs/release/staging_flutter_api_smoke.md` with an env-driven curl script. Executing that against a real hosted URL is still external; I have the runbook, not a permanent staging host in this repo.

## Testing

Every significant path I added was meant to land with tests. Flutter CI runs format, analyze, unit/widget tests, and mock integration journeys. Backend CI runs unit tests, integration tests (including Postgres data-plane coverage for stories, search, Ask, report), and an OpenAPI contract lock against `backend/contracts/openapi.v1.json`.

That does not mean device TalkBack, Play pre-launch, or a signed AAB ran here. This environment has no Android SDK (`ANDROID_HOME`). Phase 14 packaging is blocked externally; the release checklists and signing notes are ready for a host that has the SDK.

## How I run it locally

Mock client (safe default):

```bash
flutter pub get
dart run build_runner build
flutter run
```

Backend + remote client:

```bash
# Postgres via compose, or your own instance
docker compose up -d db

export ConnectionStrings__VeriMundi='Host=localhost;Port=5432;Database=verimundi;Username=verimundi;Password=verimundi'

cd backend
dotnet run --project src/VeriMundi.Api --urls http://0.0.0.0:5080
```

```bash
flutter run \
  --dart-define=NEWS_API_BASE_URL=http://localhost:5080 \
  --dart-define=APP_ENV=development
```

Swagger in Development: `http://localhost:5080/swagger`. More backend detail lives in `backend/README.md` and `docs/architecture/backend_decision.md`.

Checks I expect to stay green after meaningful changes:

```bash
dart format .
flutter analyze
flutter test
cd backend && dotnet test
```

## What is done vs what is still open

On `main` today I have a vertical slice I am willing to stand behind as engineering:

Flutter mock MVP preserved; remote repository against `/v1`; production mock forbid; typed remote errors; search and filters; offline cache honesty; choropleth map; grounded Ask with heuristic default; terms-reviewed source registry; clustering and explainable World Pulse / underreported scoring; ops auth; telemetry; OpenAPI contract CI; Postgres data-plane tests; endpoint modules instead of one giant `Program.cs`; shared rate-limit abstraction; provider/CORS hardening from the uplift stack.

What is still outside the repo — and I will not paper over it:

- Written clearance for ReliefWeb / WHO / unreviewed commercial RSS
- Production opt-in for RSS/GDELT plus the UN advise step
- Privacy policy and Play Data Safety **legal** review (the docs are engineering drafts)
- Product licence for public distribution of VeriMundi itself
- Staging host URL and production secrets
- Android SDK host, upload keystore, signed AAB, Play Console
- Device screenshots and recordings for a store listing
- Production GenAI key with real spend controls
- Notifications — the original brief truncated mid-§26; I am not inventing push requirements

VeriMundi broadens what you can see. Selection, classification, and AI-assisted summaries remain imperfect. Read them beside the original reporting.

## Docs worth opening next

- `AGENTS.md` — operating rules for humans and agents
- `docs/portfolio/engineering_evidence.md` — mock → live evidence table
- `docs/sources/source_registry.md` — what may and may not power feeds
- `docs/methodology/*` — World Pulse and underreported scoring
- `docs/ai_safety.md` — grounded generation rules
- `docs/api_contract.md` — `/v1` surface
- `docs/completion/master_completion_plan.md` — phase status
- `docs/release/*` — staging smoke, Android, Play checklists

## Licence

Licence for public distribution of this project is still undecided. Until that is settled, treat the repository as source available for review, not as a cleared redistributable product.
