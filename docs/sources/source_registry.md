# Source registry

Live VeriMundi feeds may only enable sources with status **approved**.

Statuses: `proposed` | `approved` | `restricted` | `rejected`

Scaffolded RSS/GDELT paths stay **off** until a row is both `approved` and `Enabled=true`, and the matching ingestion flag is set (`Ingestion:EnableRss` / `Ingestion:EnableGdelt`). Do not enable unapproved sources in production.

## Registry entries

| Provider/source | URL / domain | Terms / licence | Metadata | Body | Excerpt | Images | Attribution | Caching | Commercial | Cost | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| VeriMundi fixture desks (dev) | `fixture.verimundi.local.*` | Internal fixtures owned by VeriMundi | Yes | N/A (synthetic) | Yes | No | Attribute fixture desk | OK local | Dev only | Free | **approved** (non-production public marketing must still disclose fixture mode if used) |
| VeriMundi fixture wire | `fixture.verimundi.local.wire` | Internal | Yes | No | Headline/link | No | Attribute fixture wire | OK local | Dev only | Free | **approved** |
| Example commercial outlet | `example-news.example` | Unknown — not reviewed | Metadata only | No | No | No | TBD | TBD | TBD | TBD | **proposed** |
| UN News RSS | `news.un.org` | Confirm current UN News reuse / attribution terms | Often yes | No | Review | No | Per UN News terms | Per terms | Evaluate | Free feed candidate | **proposed** — seeded disabled; needs Tubo/legal approval |
| ReliefWeb updates RSS | `reliefweb.int` | Confirm ReliefWeb API/terms for headline+link caching | Often yes | No | Review | No | Per ReliefWeb | Per terms | Evaluate | Free feed candidate | **proposed** — seeded disabled |
| WHO newsroom RSS | `who.int` | Confirm WHO newsroom terms | Often yes | No | Review | No | Per WHO | Per terms | Evaluate | Free feed candidate | **proposed** — seeded disabled |
| GDELT DOC 2.0 (discovery) | `api.gdeltproject.org` / gdeltproject.org | Check current GDELT terms before production enablement | Discovery metadata / URLs | Do not treat as republish rights | No | No | Per GDELT + original publisher | Respect rate limits | Evaluate | Free tier constraints | **proposed** — feature-flagged (`EnableGdelt`), scaffold only, not enabled by default |
| Generic third-party RSS | Various | Must be reviewed per feed | Often yes | Usually no | Sometimes | Usually no | Per publisher | Per feed | Per feed | Varies | **proposed** until reviewed |

## Rules

1. Ingestion skips `rejected` and `restricted` sources for public clustering.
2. Unknown domains discovered at ingest time are auto-created as `proposed` and **disabled**.
3. Do not store full copyrighted article bodies without a verified licence (`FullTextLicensed`).
4. Production public reads must not silently substitute fixture/mock content when live mode is configured.
5. Seed upserts only add missing **proposed** rows; they never flip a source to approved/enabled.

## Approval checklist (per source)

- [ ] Terms URL captured
- [ ] Excerpt/image rights confirmed
- [ ] Attribution text confirmed
- [ ] Rate limits documented
- [ ] `LicenceStatus` set to approved and `Enabled=true` in DB seed/migration
- [ ] Matching ingestion flag documented for ops (`EnableRss` / `EnableGdelt`)

## Tubo decisions needed

Approve, restrict, or reject each **proposed** row above (especially UN News, ReliefWeb, WHO, GDELT) before any production enablement.
