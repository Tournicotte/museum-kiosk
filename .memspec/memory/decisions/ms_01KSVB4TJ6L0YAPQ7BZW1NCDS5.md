---
id: ms_01KSVB4TJ6L0YAPQ7BZW1NCDS5
type: decision
state: active
confidence: 0.9
created: '2026-05-30T00:00:00.000Z'
source: claude
tags:
  - architecture
  - trust-framework
  - autonomy-level
decay_after: '2026-11-26T00:00:00.000Z'
---
# AI agent autonomy level: L3 (Monitored) with three mandatory safeguards

Decision: AI-assisted development on this project operates at L3 autonomy (thesis §4.3.4 — Monitored: agent acts, human reviews via git diff). Three safeguards enforced in every change:

1. Constrained Operation Selection — PaymentService.charge() is the only SumUp entry point. No new platform channel methods without review.
2. Read-Only Default — Admin panel is read-only. Destructive operations (refunds, order deletion) require backend API, not client-side agent code.
3. Blast Radius Control — Payment, database, and UI are isolated layers. A bug in one cannot silently corrupt another. No shared mutable globals.

Trust equation (thesis §4.3.2): Effective Trust = (Observability × Reversibility × Blast Radius) / Autonomy.
At L3: Observability = every payment event logged with orderId; Reversibility = orders are DB records, voidable via admin; Blast Radius = bounded to single operation per SumUp call.
