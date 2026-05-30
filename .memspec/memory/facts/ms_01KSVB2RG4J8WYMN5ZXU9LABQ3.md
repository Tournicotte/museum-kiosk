---
id: ms_01KSVB2RG4J8WYMN5ZXU9LABQ3
type: fact
state: active
confidence: 0.9
created: '2026-05-30T00:00:00.000Z'
source: claude
tags:
  - stack
  - flutter
  - dart
  - dependencies
decay_after: '2026-08-28T00:00:00.000Z'
---
# Tech stack: Flutter/Dart, Riverpod, GoRouter, Drift, SumUp platform channel

- Dart 3.4+ strict analysis (strict-casts, strict-inference, strict-raw-types)
- Flutter Android only (--platforms android)
- State: Riverpod 2.x with @riverpod code generation
- Navigation: GoRouter — named constrained routes, no back nav in payment flow
- Local DB: Drift (type-safe SQLite) — KioskDatabase (Orders + TicketTypes tables)
- Payments: SumUp Android SDK via Flutter platform channel `ee.kaasan.museum_kiosk/sumup`
- Serialization: freezed + json_annotation
- Logging: Dart logging package — Logger('kiosk.<feature>') hierarchy
- Kiosk helpers: wakelock_plus + SystemChrome.immersiveSticky

Code generation: `dart run build_runner build --delete-conflicting-outputs` — run after any change to @riverpod, @freezed, or @DriftDatabase annotated code. Generated files (*.g.dart, *.freezed.dart) are committed.
