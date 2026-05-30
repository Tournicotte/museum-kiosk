---
id: ms_01KSVB1QF3H7VXNM4YWT8KZAP2
type: fact
state: active
confidence: 0.9
created: '2026-05-30T00:00:00.000Z'
source: claude
tags:
  - project
  - kiosk
  - android
decay_after: '2026-08-28T00:00:00.000Z'
---
# Project: unattended public museum ticket kiosk on Android tablet

Self-service ticket kiosk for a museum. Runs on an Android tablet mounted in public space. Package `ee.kaasan.museum_kiosk` (org: kaasan.ee, owner: Catherine). Android only — iOS excluded. Flutter/Dart, SumUp card reader for payments.

Primary constraints: unattended public device (no cash, no QR billing, card only), must work offline (local SQLite), landscape only, large touch targets, system UI hidden, no escape to home screen for public users.
