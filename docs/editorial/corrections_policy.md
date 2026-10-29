# Corrections policy

News products must not silently rewrite important factual changes.

## Principles

1. Material factual changes to summaries or confirmed facts create a **corrected** verification state where appropriate.
2. Correction notices must be visible in the story detail experience (`correctionNotice`, `correctedAt`).
3. Previous summary history should be retained where practical (timeline / history endpoint).
4. Source removal (broken URL, rights revocation, proven fabrication) triggers re-evaluation and may set `insufficientEvidence`.
5. Major corrections should trigger re-synthesis from remaining approved evidence.

## User reports (shipped UI + API)

Users may report from story detail:

| Reason (allowlisted) |
| --- |
| Incorrect summary |
| Unsupported claim |
| Outdated information |
| Misleading classification |
| Broken source |
| Other |

- Flutter: report dialog with privacy notice; mock mode does **not** claim server submission.
- API: `POST /v1/stories/{storyId}/reports` — allowlisted reason; optional details ≤500 chars; `202 Accepted` with report id.
- Handling today: structured operational log (reason + details **length** only) for operators; **no** durable public moderation queue yet. Follow-up is a manual/ops process.
- Abuse controls: global write rate limit + dedicated `report_rate_limited` (see `docs/editorial/abuse_prevention.md`).

## Operator follow-up (expected)

1. Triage logged reports by reason.
2. Verify against linked sources; apply correction notice / re-synthesis when material.
3. If a source must be removed for rights or fabrication, revoke and re-score.
4. Do not silently alter past user-visible claims without a correction signal.

## External / still open

- Staffed moderation workflow / ticket store (product ops).
- Public corrections log page (optional).
- Legal review of user-facing privacy copy that describes reports (**EXTERNAL**).
