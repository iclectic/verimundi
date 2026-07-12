# VeriMundi Product Spec

## Target Users

- Readers who want a broader view of global developments.
- Researchers, educators, and analysts tracking local coverage signals.
- People who want constructive news without losing uncertainty and source context.

## User Problems

- Major feeds overrepresent already prominent countries and high-engagement narratives.
- Local coverage can signal important developments before international coverage appears.
- AI summaries can hide uncertainty unless source grounding is explicit.
- Positive developments are often mixed into generic news feeds or exaggerated.

## Product Principles

- Importance is not the same as popularity.
- Severity and tone are separate.
- Positive does not mean solved.
- AI output must be labeled and grounded.
- Source coverage and uncertainty should be visible, not hidden behind summary text.

## Main Journeys

1. Open the World dashboard and scan active country markers.
2. Switch perspective between World Pulse, Underreported, and Positive World.
3. Filter or search by region, country, category, severity, tone, verification, local coverage, or date range.
4. Open a story, compare sources, read confirmed facts and uncertainty, then ask a grounded mock question.
5. Save stories and return to them later.

## Definitions

Severity:

- Critical: immediate danger, large-scale displacement, severe disaster, or another urgent event.
- Serious: major consequences without the same immediate danger.
- Developing: important information is emerging and scale remains uncertain.
- General: relevant news without immediate severe threat.

Tone:

- Positive: constructive development with meaningful evidence.
- Neutral: informational or procedural.
- Concerning: risk, disruption, harm, or warning.
- Mixed: contains constructive and concerning elements.

Verification:

- Confirmed, developing, disputed, corrected, insufficient evidence.

## MVP Scope

The MVP includes local mock data, world dashboard, global feed, underreported feed, positive feed, detail pages, source comparison, saved stories, filters, settings, mock AI summaries, mock story questions, and light/dark themes.

## Non-Goals

- Live news ingestion.
- Real GenAI provider calls from the client.
- Editorial credibility scoring methodology.
- Account sync.
- Push notifications.

## Future Capabilities

- Multilingual ingestion and translation.
- RSS and licensed provider integrations.
- Story clustering and deduplication.
- Country-polygon choropleth map.
- Transparent source credibility methodology.
- User accounts and synchronized bookmarks.
- Story update notifications.
