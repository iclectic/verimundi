# Source registry

Live VeriMundi feeds may only enable sources with status **approved**.

Statuses: `proposed` | `approved` | `restricted` | `rejected`

RSS/GDELT paths stay **off** until a row is both `approved` and `Enabled=true`, and the matching ingestion flag is set (`Ingestion:EnableRss` / `Ingestion:EnableGdelt`). Do not enable unapproved or restricted sources in production.

**Review date:** 2026-10-26. Approvals below are based on publicly posted terms only — not a substitute for counsel. No fake clearances.

## Registry entries

| Provider/source | URL / domain | Terms / licence | Metadata | Body | Excerpt | Images | Attribution | Caching | Commercial | Cost | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| VeriMundi fixture desks (dev) | `fixture.verimundi.local.*` | Internal fixtures owned by VeriMundi | Yes | N/A (synthetic) | Yes | No | Attribute fixture desk | OK local | Dev only | Free | **approved** (non-production public marketing must still disclose fixture mode if used) |
| VeriMundi fixture wire | `fixture.verimundi.local.wire` | Internal | Yes | No | Headline/link | No | Attribute fixture wire | OK local | Dev only | Free | **approved** |
| Example commercial outlet | `example-news.example` | Unknown — not reviewed | Metadata only | No | No | No | TBD | TBD | TBD | TBD | **proposed** |
| UN News RSS | `news.un.org` | [Navigate the News](https://news.un.org/en/content/navigate-news) invites use/feature/repurpose with UN News attribution + link-back; [UN Copyright](https://www.un.org/en/about-us/copyright/) allows news-related material with credit and advising the UN. RSS publishes headlines/summaries. No photos/AV without separate clearance. | Yes | No full-body scrape | Short RSS summary OK | No | “UN News” + story URL | Headline/excerpt + link OK | Allowed under posted UN News reuse language | Free | **approved** + `Enabled=true` — ops must advise UN (`unnews@un.org`) when enabling production |
| ReliefWeb updates RSS | `reliefweb.int` | [Terms & Conditions](https://reliefweb.int/terms-conditions): personal **non-commercial** download/copy; **no** resale, redistribute, or derivative compilation. Partner IP still applies. API needs approved `appname`. | Maybe with clearance | No | No without clearance | No | Per partner + ReliefWeb | Not for product aggregation | **Blocked** without written OCHA/ReliefWeb clearance | Free feed exists | **restricted** + disabled |
| WHO newsroom RSS | `who.int` | [WHO website copyright](https://www.who.int/about/policies/terms-of-use): extracts for research/private study only; **not for sale or commercial purposes** without prior written authorisation. AFRO RSS page points at WHO copyright. | Maybe with written OK | No | No without written OK | No | WHO + URL | Not for product aggregation | **Blocked** pending written WHO permission | Free feed exists | **restricted** + disabled |
| GDELT DOC 2.0 (discovery) | `api.gdeltproject.org` | [GDELT About / Terms](https://www.gdeltproject.org/about.html): GDELT **datasets** free for academic/commercial/gov use with citation + link to gdeltproject.org. **Does not** licence underlying publisher headlines, bodies, or images. | Discovery URLs + GDELT fields | Never | No publisher excerpt via GDELT | No | Cite GDELT Project; publisher rights separate | Respect polite rate use | GDELT metadata OK; publisher content not included | Free DOC API | **approved** MetadataOnly + `Enabled=true` — pipeline still requires each publisher domain approved before article ingest |
| Generic third-party RSS | Various | Must be reviewed per feed | Often yes | Usually no | Sometimes | Usually no | Per publisher | Per feed | Per feed | Varies | **proposed** until reviewed |

## Rules

1. Ingestion skips `rejected` and `restricted` sources for public clustering.
2. Unknown domains discovered at ingest time are auto-created as `proposed` and **disabled**.
3. Do not store full copyrighted article bodies without a verified licence (`FullTextLicensed`).
4. Production public reads must not silently substitute fixture/mock content when live mode is configured.
5. Seed **syncs curated registry rows** (including approvals/restrictions) to match this document. It never auto-approves unknown discovered domains.
6. GDELT hits are attributed to the **publisher domain** from the URL. Unapproved publishers are skipped (may be proposed). GDELT itself is not a republish licence.
7. RSS stores excerpts only when `ContentUsageStatus` is `PermittedExcerpt` or `FullTextLicensed`.

## Approval checklist (per source)

- [x] Terms URL captured (UN, ReliefWeb, WHO, GDELT — see table)
- [x] Excerpt/image rights confirmed (UN: short RSS excerpt, no images; GDELT: no excerpt; ReliefWeb/WHO: blocked)
- [x] Attribution text confirmed (seeded on Source rows)
- [x] Rate limits documented (ReliefWeb API 1000/day if ever cleared; GDELT: polite/reasonable use, no key)
- [x] `LicenceStatus` + `Enabled` set in DB seed for reviewed rows
- [x] Matching ingestion flags documented (`EnableRss` / `EnableGdelt`)

## Ops flags

| Flag | When to set `true` |
| --- | --- |
| `Ingestion:EnableRss` | Local/staging/production after UN (or other approved feeds) are seeded enabled. Development defaults on; production base `appsettings.json` stays off until ops opts in. |
| `Ingestion:EnableGdelt` | After accepting MetadataOnly constraints above. Discovers URLs only; does not by itself create stories from unapproved publishers. |
| `Ingestion:GdeltQuery` | Optional DOC query (default `sourcelang:english`). |

## Still blocked / needs human decision

| Item | Why |
| --- | --- |
| ReliefWeb product use | Site T&Cs are personal non-commercial; partner copyrights |
| WHO product use | Commercial use needs prior written WHO authorisation |
| Example commercial outlet | No terms review |
| Production UN “advise UN” notice | Process obligation when flipping production flags |
| Any new RSS domain | Per-feed legal review before seed approval |
