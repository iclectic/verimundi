# World map GeoJSON status

## Current behaviour

The Flutter world map (`lib/features/world/presentation/world_map_view.dart`) uses:

- **Country-polygon choropleth** from vendored Natural Earth 1:110m Admin-0 geometries
- Severity fill **plus** hatch patterns and centroid icons/labels (not colour alone)
- Zoom/pan (`InteractiveViewer`) and tap hit-testing on polygons
- Country **detail panel** (bottom sheet) with severity pill, counts, leading stories, filter action
- Accessible **country list** alternative: search, sort, severity chips (icon + text), active-only, live counts

## Licence-cleared asset

| Item | Value |
| --- | --- |
| Path | `assets/geo/countries_110m.geojson` (~170 KB simplified) |
| Licence notes | `assets/geo/LICENSE.md` |
| Source | Natural Earth Admin 0 – Countries, 1:110m |
| Terms | [Natural Earth Terms of Use](https://www.naturalearthdata.com/about/terms-of-use/) — **public domain**; commercial use allowed; attribution optional (“Made with Natural Earth”) |
| Properties kept | `isoA2`, `name` (coordinates rounded to 2 dp) |

This is **not** an invented clearance: Natural Earth’s published terms place the vector data in the public domain. Boundaries follow Natural Earth’s de facto Admin-0 view and are not a VeriMundi political endorsement.

## When regenerating

1. Start from Natural Earth 110m Admin-0 countries GeoJSON.
2. Keep features with a usable ISO-3166 alpha-2 code (`ISO_A2_EH` / `ISO_A2`).
3. Emit only `isoA2` + `name`; round coordinates; update `LICENSE.md` retrieval note if the upstream revision changes.
4. Keep list/a11y path and severity non-colour cues when changing painters.
