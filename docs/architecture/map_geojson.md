# World map GeoJSON status

## Current behaviour

The Flutter world map (`lib/features/world/presentation/world_map_view.dart`) uses:

- Equirectangular marker placement from country lat/long
- Regional severity tint bands
- Severity icons and text labels (not colour alone)
- Zoom/pan gestures
- An accessible **country list** alternative (toggle on the map screen) with:
  - Search by country / region / code
  - Sort by severity, name, or active story count
  - “Active stories only” and severity chips (icon + text)
  - Live result count and empty-state reset (including clear region)

This satisfies Phase 8 accessibility and interactive overview without shipping third-party polygon assets.

## Choropleth blocker

A true country-polygon choropleth needs a **licence-cleared** GeoJSON (or similar) dataset suitable for app distribution. No such asset is committed today.

Until Tubo selects and clears a dataset:

1. Keep markers + list path as the production map UX.
2. Do not vendor Natural Earth / other map data without recording licence and attribution.
3. Prefer improving list/a11y and severity legend polish over speculative asset downloads.

## When unblocked

1. Place the licensed asset under an agreed path (e.g. `assets/geo/`).
2. Record licence + attribution in this doc and the app About/Settings copy if required.
3. Replace marker painting with polygon fills keyed by `CountryNewsStatus` severity.
