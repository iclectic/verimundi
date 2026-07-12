# Future REST API Contract

The Flutter client reads the future base URL from:

```text
--dart-define=NEWS_API_BASE_URL=...
```

The default value is `mock`, which keeps the app in local demo mode.

## Endpoints

- `GET /v1/world/status`
- `GET /v1/regions`
- `GET /v1/countries`
- `GET /v1/countries/{countryCode}/stories`
- `GET /v1/stories`
- `GET /v1/stories/{storyId}`
- `GET /v1/stories/{storyId}/sources`
- `GET /v1/stories/underreported`
- `GET /v1/stories/positive`
- `POST /v1/stories/{storyId}/questions`
- `POST /v1/users/me/saved-stories`
- `DELETE /v1/users/me/saved-stories/{storyId}`

## Example Story Response

```json
{
  "id": "story-001",
  "headline": "River districts test new flood warning sirens",
  "shortSummary": "Local agencies are testing sirens and text alerts.",
  "whyItMatters": "Early warnings can reduce harm when flooding develops quickly.",
  "countryCodes": ["NP"],
  "primaryCountryCode": "NP",
  "region": "Asia",
  "category": "climate",
  "severity": "critical",
  "severityReason": "Forecast river levels may require urgent evacuation planning.",
  "tone": "concerning",
  "verificationStatus": "developing",
  "confidenceScore": 0.74,
  "sourceArticles": []
}
```

## Example Question Request

```json
{
  "question": "What remains uncertain?",
  "sourceIds": ["story-001-src-1", "story-001-src-2"]
}
```

## Example Question Response

```json
{
  "answer": "Forecast rainfall totals and evacuation needs remain uncertain.",
  "insufficientEvidence": false,
  "confidenceScore": 0.72,
  "sourceIds": ["story-001-src-1", "story-001-src-2"],
  "generatedAt": "2026-07-12T12:00:00Z"
}
```

## Saved Story Request

```json
{
  "storyId": "story-001",
  "headlineSnapshot": "River districts test new flood warning sirens",
  "country": "NP",
  "summarySnapshot": "Local agencies are testing sirens and text alerts.",
  "verificationStatus": "developing",
  "lastKnownSourceCount": 9
}
```
