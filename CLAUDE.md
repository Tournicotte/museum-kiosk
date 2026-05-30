# museum_kiosk

Self-service ticket kiosk for a museum. Android tablet. Flutter/Dart. SumUp card payments.
Package: `ee.kaasan.museum_kiosk`

> Full, authoritative standards live in `.cursor/rules/**`.
> This file is the distilled, always-on summary for AI agents. When in doubt, read the matching `.mdc` rule. Do not contradict the rules.

## Before you start

- **Read `docs/agent-memory.md`** first; append corrections after fixing any mistake or deprecation.
- **`docs/implementation-plan.md`** is the single source of truth for status/roadmap. Check it before planning; update it after milestones.
- **memspec**: project memory lives in `.memspec/`. Search it first: `memspec search <topic>`. A recorded decision outweighs inference from code structure.

## Repository layout

```
lib/
  app/              MaterialApp, GoRouter (constrained routes), theme
  core/
    config/         AppConfig.fromEnvironment() — all config via --dart-define
    logging/        Logger hierarchy — structured, no print()
    errors/         Sealed AppError — every failure site is named
    database/       Drift (SQLite) — local order log, cached ticket types
    payment/        PaymentService interface + SumUp platform channel
  features/
    attract/        Idle screen — tap anywhere to start
    ticket_selection/  Pick ticket types + quantities
    payment/        SumUp charge — one operation, no back nav
    confirmation/   Success + 15s auto-return
    admin/          PIN-gated, read-only staff panel
android/            Native Android project (kiosk manifest, SumUpPlugin.kt)
docs/               agent-memory.md, implementation-plan.md
.cursor/            rules, skills, commands, prompts, hooks
.memspec/           structured project memory
```

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze && dart format --output=none --set-exit-if-changed lib/
flutter test
flutter build apk \
  --dart-define=ENV=production \
  --dart-define=MUSEUM_NAME="..." \
  --dart-define=SUMUP_AFFILIATE_KEY=xxx \
  --dart-define=ADMIN_PIN=xxxx
```

## Flutter/Dart conventions (`.cursor/rules/flutter-dart/*`)

- Feature-first structure. Core cross-cutting concerns in `lib/core/`.
- `@riverpod` annotated providers — run codegen after any change. Never hand-edit `*.g.dart` or `*.freezed.dart`.
- Immutable data classes with `@freezed`. State updates via `copyWith` only.
- GoRouter named routes — no ad-hoc `Navigator.push`. No back nav once inside payment flow.
- No `dynamic` outside generated files. No `print()` — use `Logger('kiosk.<feature>')`.
- `always_use_package_imports` enforced. `prefer_single_quotes` enforced.
- Config via `AppConfig.fromEnvironment()` — **no module-level singletons**, all values from `--dart-define`.

## Kiosk rules (`.cursor/rules/android-kiosk/kiosk-rules.mdc`)

- Screen always on (`WakelockPlus.enable()`), landscape only, system UI hidden (`SystemUiMode.immersiveSticky`).
- `PopScope(canPop: false)` on Payment and Confirmation screens — no back escape.
- Idle timeout (default 60 s) resets any screen to Attract.
- Admin is PIN-gated. **Read-only by default** — no destructive operations exposed in the UI.

## Payment — Constrained Operation Selection (`.cursor/rules/android-kiosk/sumup-payments.mdc`)

`PaymentService.charge()` is the **only** permitted payment operation. No new platform-channel calls. No direct SumUp SDK access outside `SumUpPaymentService`. This is non-negotiable.

Thesis basis (§4.X): LLM/agent selects from predefined operations; deterministic code executes. This eliminates the failure class where an agent or bug reaches destructive action space (cf. Amazon Kiro incident, Dec 2025 — 13-hour outage caused by agent choosing delete+recreate over incremental fix because it was not constrained).

## Security (`.cursor/rules/common/security.mdc`)

- All secrets via `--dart-define`. Never hardcoded. Never in source control.
- Log payment events with `orderId` and outcome. **Never log card data, PAN, CVV, or PII.**
- Admin PIN compared in constant-time; never logged, never stored in plaintext DB.
- SumUp Bluetooth permissions in manifest with correct `android:required` annotations.

## Deployment (`.cursor/rules/common/deployment.mdc`)

- APK built locally, installed on tablet via `adb install` or MDM. Never push to tablet from a dev machine in any other way.
- Drift schema changes are versioned migration steps — never `destroyEverything` outside dev.
- Run `memspec search deploy` for the recorded tablet provisioning procedure.

## Workflow

- Git: always `git --no-pager` for log/diff/show (`.cursor/rules/ai-tools/git-commands.mdc`).
- After substantial work: run **quality-check** skill (simplifier → security-check → code-review → flutter analyze + tests).
- Code in English; UTF-8; remove dead code; committed `pubspec.lock` is the version lock.

<!-- memspec:init:start -->
## Memory (Memspec)

This project uses Memspec for structured memory. `.memspec/` is the canonical store for durable project knowledge. Memspec is agent-operated, not human-curated.

### On session start
Relevant active memories are auto-injected via `memspec context` on `SessionStart`. As a fallback: `memspec search <topic>`. Prefer active memories over stale assumptions.

If `memspec` is not on PATH: it is a Node tool — run `npm link` in the memspec checkout, or invoke as `node <memspec-repo>/dist/cli.js <command>`. Do not conclude it is missing without checking.

### Retrieve before assuming
Before acting on any assumption about how this project works, search memspec for:
- **Operational knowledge** — deploy steps, tablet setup, SumUp key location, established workflows
- **Architectural decisions** — stack choices, payment isolation, component boundaries, data models
- **Project conventions** — naming, file structure, testing strategy, code style rationale

A recorded decision outweighs what the codebase appears to suggest — memory captures *why*, code only shows *what*.

### When to write memories
Write or correct memories immediately after:
- **Fixed a bug** → correct the relevant `fact` about system behaviour
- **Changed architecture or config** → correct stale `decision`/`fact`, write new ones
- **Established a workflow** → write a `procedure`
- **Discovered something non-obvious** → write a `fact`
- **Made a design choice** between alternatives → write a `decision` with rationale

```
memspec add <type> "<title>" --body "<content>" --source claude --tags <tags>
memspec correct <id> --reason "<why>" --replace "<new content>"
```

### Guidelines
- Only write knowledge useful to a future agent starting cold. No session transcripts.
- Never store secrets, card data, or PII in memory files.
- Correct stale memories — never leave two contradicting active memories.
- Classification: *why* → decision, *how to do X* → procedure, *what is true* → fact.
<!-- memspec:init:end -->
