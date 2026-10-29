# GDELT DOC 2.0 — VeriMundi constraints

**Status:** approved for **MetadataOnly** discovery (`LicenceStatus=Approved`, `Enabled=true`, `ContentUsageStatus=MetadataOnly`).

## What GDELT licences

Per [GDELT Project About / Terms of Use](https://www.gdeltproject.org/about.html):

- GDELT **datasets** may be used for academic, commercial, or governmental purposes without fee.
- Redistribution must **cite the GDELT Project** and link to `https://www.gdeltproject.org/`.

## What GDELT does **not** licence

- Original publisher **article bodies**
- Publisher **headlines**, images, or other protected material merely because a URL appears in DOC ArtList
- Any implication that VeriMundi may republish third-party newsrooms without their own approval

## How VeriMundi uses it

1. `Ingestion:EnableGdelt=true` registers `GdeltDiscoveryProvider`.
2. Provider calls DOC 2.0 `mode=ArtList&format=json` (no API key).
3. Each hit becomes a candidate attributed to the **publisher domain** from the URL.
4. `IngestionPipeline` still skips `proposed` / `restricted` / `rejected` publishers (may create proposed rows for unknown domains).
5. No excerpts or images are taken from GDELT responses.
6. Stories only form when the publisher domain is separately **approved** (e.g. `news.un.org` via RSS remains the primary live feed path).

## Ops

| Key | Notes |
| --- | --- |
| `Ingestion:EnableGdelt` | Off in production base config; on in Development / docker-compose |
| `Ingestion:GdeltQuery` | Default `sourcelang:english`; keep queries narrow to limit volume |
| Rate use | No documented hard DOC quota — use polite intervals; hosted worker already cycles |

## Do not

- Store full HTML from publisher URLs discovered via GDELT
- Mark GDELT hits as `FullTextLicensed`
- Enable GDELT Cloud commercial products under this approval (separate product/terms)
