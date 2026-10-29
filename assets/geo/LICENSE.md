# World countries GeoJSON — licence

**File:** `countries_110m.geojson`  
**Source:** Natural Earth Admin 0 – Countries at 1:110m  
**Upstream:** https://www.naturalearthdata.com/ (vector GeoJSON via natural-earth-vector)  
**Terms:** https://www.naturalearthdata.com/about/terms-of-use/

Natural Earth states that its raster and vector map data are in the **public domain**. No permission is required for personal, educational, or commercial use. Crediting the authors is unnecessary; if citing, Natural Earth suggests: “Made with Natural Earth.”

## What VeriMundi changed

- Kept only `isoA2` and `name` properties (from Natural Earth `ISO_A2_EH` / `NAME_EN` fields).
- Dropped features without a usable ISO-3166 alpha-2 code.
- Rounded coordinates to 2 decimal places to shrink the asset.

## Disclaimer

Boundary representation follows Natural Earth’s de facto Admin-0 dataset and is **not** VeriMundi’s political endorsement of any claim. Story severity fills are VeriMundi product data overlaid on these geometries.
