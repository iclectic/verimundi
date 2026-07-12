# VeriMundi AI Safety

## Grounded Generation

AI may only summarize text supplied from selected source articles. It must not rely on unsupported model memory for current facts.

## Structured Output

Future AI responses should use structured JSON:

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
  "uncertainties": [],
  "severity": "",
  "severityReason": "",
  "tone": "",
  "confidenceScore": 0,
  "insufficientEvidence": false
}
```

## Source Grounding

Every confirmed fact must reference one or more source IDs. When supplied articles disagree, the AI must report disagreement rather than choosing a claim without explanation.

## Insufficient Evidence

When sources do not support a reliable summary, return:

```json
{
  "insufficientEvidence": true
}
```

The UI should show:

> VeriMundi does not currently have enough reliable source material to summarise this story.

## AI Transparency

Clearly label AI-generated summaries, AI-generated answers, confidence values, generation timestamps, and source material used.

Do not describe the AI as unbiased or completely objective.

## Client-Side Rule

The Flutter client must never call a commercial GenAI provider directly using a secret API key. Real GenAI operations must pass through a secure backend.
