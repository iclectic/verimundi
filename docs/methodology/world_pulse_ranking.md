# World Pulse ranking

## Goal

Present important current developments without letting high-volume regions dominate solely by article count.

## Composite importance (explainable)

Factors currently used server-side (`WorldPulseRanker`):

| Factor | Role |
| --- | --- |
| Severity | Critical > serious > developing > general |
| Recency | Fresher updates score higher |
| Independent sources | Distinct domains, not raw article count |
| Verification confidence | Down-weights thin evidence |

## Regional diversity reservation

Supported regions:

- Africa
- Asia
- Europe
- Middle East
- North America
- Latin America and the Caribbean
- Oceania

Algorithm:

1. From active stories, compute importance.
2. Reserve up to one story per region (best available in that region).
3. Fill remaining slots by global importance order.

Each story exposes a human-readable `rankingReason`.

## Non-goals

- Hidden editorial favouritism without documentation
- Engagement/popularity as the sole sort key
- Fabricated casualty or impact numbers
