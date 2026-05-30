---
id: ms_01KSVB3SH5K9XZNP6AYV0MBCR4
type: decision
state: active
confidence: 0.9
created: '2026-05-30T00:00:00.000Z'
source: claude
tags:
  - sumup
  - payments
  - platform-channel
  - constrained-operations
decay_after: '2026-11-26T00:00:00.000Z'
---
# SumUp via platform channel with Constrained Operation Selection

Decision: integrate SumUp Android SDK via a Flutter platform channel exposing exactly one operation: `charge`. No pub.dev wrapper.

Why: No official first-party SumUp Flutter package. Community wrappers are unmaintained. The native Android SDK (Maven: `com.sumup-merchant.api:android-sdk:4.2.0`) is the authoritative path.

Constrained Operation Selection (thesis §4.X): PaymentService.charge() is the only permitted operation. The caller cannot construct arbitrary SDK calls. This pattern prevents the failure class where an agent or bug reaches destructive action space (Amazon Kiro incident, Dec 2025: agent deleted production environment because delete+recreate was reachable). By making all operations other than `charge` architecturally unreachable, blast radius is bounded.

Channel: `ee.kaasan.museum_kiosk/sumup`. Kotlin host: `android/.../SumUpPlugin.kt` (Phase 3).
Dev fallback: StubPaymentService — 2s fake successful charge. Injected via ProviderScope override.
