# VeriMundi AI Safety

## Grounded Generation

AI may only summarize text supplied from selected source articles. It must not rely on unsupported model memory for current facts.

Never invent casualties, quotations, statistics, or named officials that are not present in the supplied evidence.

## Structured Output

Synthesis and Ask responses use structured JSON (heuristic path builds the same shape in-process; GenAI requests `response_format=json_object`):

```json
{
  "summary": "",
  "whyItMatters": "",
  "confirmedFacts": [
    {
      "text": "",
      "sourceIds": []
    }
  ],
  "disputedClaims": [
    {
      "text": "",
      "supportingSourceIds": [],
      "disputingSourceIds": []
    }
  ],
  "uncertainties": [],
  "severity": "developing",
  "severityReason": "",
  "tone": "neutral",
  "confidenceScore": 0,
  "insufficientEvidence": false
}
```

Ask VeriMundi:

```json
{
  "answer": "",
  "sourceIds": [],
  "confidence": 0,
  "uncertainty": "",
  "insufficientEvidence": false
}
```

## Source Grounding

Every confirmed fact must reference one or more source IDs from the supplied evidence set. Unknown IDs are stripped server-side. When supplied articles disagree, the AI must report disagreement in `disputedClaims` rather than silently choosing a claim.

## Insufficient Evidence

When sources do not support a reliable summary or answer, return:

```json
{
  "insufficientEvidence": true
}
```

The UI should show:

> VeriMundi does not currently have enough reliable source material to summarise this story.

Certainty / “prove” prompts on Ask are rejected as insufficient evidence even when sources exist.

## AI Transparency

Clearly label AI-generated summaries, AI-generated answers, confidence values, generation timestamps, and source material used.

Do not describe the AI as unbiased or completely objective.

`GET /v1/app/config` exposes `ai.provider` as `heuristic` or `openaiCompatible` so clients can be honest about the path without receiving secrets.

## Client-Side Rule

The Flutter client must never call a commercial GenAI provider directly using a secret API key. Real GenAI operations must pass through a secure backend.

## Backend synthesis (current)

The ASP.NET host exposes grounded synthesis and Ask VeriMundi via `IAiSynthesisService`.

| Mode | When | Behaviour |
| --- | --- | --- |
| **Heuristic** (default) | `Ai:ApiKey` / `OPENAI_API_KEY` empty | Deterministic grounded synthesis/Ask; no network GenAI |
| **OpenAI-compatible** | Non-empty API key in host env/secret store | Chat completions with grounded JSON; source IDs validated; falls back to heuristic on transport/parse failure |

Configuration (host only — never Flutter):

- `Ai:ApiKey` or `OPENAI_API_KEY`
- `Ai:BaseUrl` (default `https://api.openai.com/v1`)
- `Ai:Model` (default `gpt-4o-mini`)
- `Ai:AskPerMinutePerIp` (default `10`) — stricter Ask rate limit (`ask_rate_limited`) in addition to the global write limiter

Evaluation fixtures for insufficient-evidence / certainty / disputed-claim expectations live under `backend/tests/VeriMundi.UnitTests/Fixtures/ai_eval_cases.json`.
