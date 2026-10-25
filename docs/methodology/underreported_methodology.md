# Underreported methodology

## Intent

Surface stories with meaningful local/regional evidence and comparatively lower international coverage. Scores are **discovery aids**, not claims that a story is being deliberately ignored.

## Signals

```text
underreported score ≈
  importance(severity)
  × local/regional evidence strength
  × international coverage gap
  × independent-source adjustment
  × confidence adjustment
```

Implemented in:

- Flutter mock: `UnderreportedScoringService`
- Backend: `VeriMundi.Application.Scoring.UnderreportedScorer`

## Explanation copy

Every displayed underreported result should include a reason such as:

> Covered by 11 local or regional sources but only 1 international source (5 independent). This provisional score is a discovery aid, not a judgement of objective importance.

Forbidden without evidence:

> Western media is ignoring this.

## Calibration

Weights will be revisited as live corpora grow. Prefer explainable adjustments over opaque model scores.
