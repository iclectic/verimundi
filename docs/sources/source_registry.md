# Source registry

Live VeriMundi feeds may only enable sources with status **approved**.

Statuses: `proposed` | `approved` | `restricted` | `rejected`

## Registry entries

| Provider/source | URL / domain | Terms / licence | Metadata | Body | Excerpt | Images | Attribution | Caching | Commercial | Cost | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| VeriMundi fixture desks (dev) | `fixture.verimundi.local.*` | Internal fixtures owned by VeriMundi | Yes | N/A (synthetic) | Yes | No | Attribute fixture desk | OK local | Dev only | Free | **approved** (non-production public marketing must still disclose fixture mode if used) |
| VeriMundi fixture wire | `fixture.verimundi.local.wire` | Internal | Yes | No | Headline/link | No | Attribute fixture wire | OK local | Dev only | Free | **approved** |
| Example commercial outlet | `example-news.example` | Unknown — not reviewed | Metadata only | No | No | No | TBD | TBD | TBD | TBD | **proposed** |
| GDELT DOC 2.0 (discovery) | gdeltproject.org APIs | Check current GDELT terms before production enablement | Discovery metadata / URLs | Do not treat as republish rights | No | No | Per GDELT + original publisher | Respect rate limits | Evaluate | Free tier constraints | **proposed** — feature-flagged, not enabled by default |
| Generic third-party RSS | Various | Must be reviewed per feed | Often yes | Usually no | Sometimes | Usually no | Per publisher | Per feed | Per feed | Varies | **proposed** until reviewed |

## Rules

1. Ingestion skips `rejected` and `restricted` sources for public clustering.
2. Unknown domains discovered at ingest time are auto-created as `proposed` and **disabled**.
3. Do not store full copyrighted article bodies without a verified licence (`FullTextLicensed`).
4. Production public reads must not silently substitute fixture/mock content when live mode is configured.

## Approval checklist

- [ ] Terms URL captured
- [ ] Excerpt/image rights confirmed
- [ ] Attribution text confirmed
- [ ] Rate limits documented
- [ ] `LicenceStatus` set to approved and `Enabled=true` in DB seed/migration
