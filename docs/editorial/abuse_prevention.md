# Abuse prevention (Ask, reports, writes)

Lightweight API controls for spam and cost abuse. **Not** a substitute for edge WAF / CDN rate limits in production hosting.

## Limits (current)

| Layer | Scope | Default | Error `code` | Retry-After |
| --- | --- | --- | --- | --- |
| `SimpleRateLimitMiddleware` | All POST/PUT/DELETE | 30 / IP / minute | `rate_limited` | ≈60s |
| `AskRateLimitMiddleware` | `POST …/questions` | `Ai:AskPerMinutePerIp` (default 10) | `ask_rate_limited` | ≈60s |
| `ReportRateLimitMiddleware` | `POST …/reports` | 10 / IP / minute | `report_rate_limited` | ≈60s |

Ask and report limits run **in addition** to the global write limiter.

## Report hardening

- Reason must match the allowlist in `StoryReportReasons` / Flutter `ReportReasons` (no free-form categories).
- Details capped at 500 characters; free-text is not written to application logs.
- Story must exist (`story_not_found` otherwise).
- Ops admin ingestion remains token-gated (`Ops:AdminIngestionToken`) and is unrelated to end-user reports.

## Flutter behaviour

- Maps `rate_limited`, `ask_rate_limited`, and `report_rate_limited` to `RemoteApiErrorKind.rateLimited`.
- Client-side validation for Ask length and report reason/details before POST.
- Mock/demo builds do not send reports or Ask to a network API.

## Production recommendations (ops — external hosting)

1. Put Cloudflare / cloud armour / API gateway limits in front of the ASP.NET host.
2. Prefer forwarding client IP via trusted proxy headers only after hardening `ForwardedHeaders`.
3. Alert on spikes of `429` / report log volume.
4. Keep GenAI spend caps when `Ai:ApiKey` is set.
