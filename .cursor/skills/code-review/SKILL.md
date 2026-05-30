---
name: code-review
description: Review changed code for correctness bugs, standards violations, and simplification opportunities. Use when asked to review, check code quality, or as part of quality-check.
---

# Code Review

Review the current diff for correctness bugs and standards violations against `.cursor/rules/**`.

## Scope

- Prefer files changed in the current session.
- If session scope is unclear, inspect `git --no-pager diff` and `git --no-pager diff --cached`.

## Review Checklist

### Correctness
- Are all `AsyncValue` states handled (data, loading, error)?
- Are `Timer` instances cancelled in `dispose()`?
- Is `mounted` checked before using `BuildContext` after `await`?
- Are DB writes confirmed before UI state advances?
- Is `PaymentService.charge()` the only SumUp call?

### Standards (`.cursor/rules/flutter-dart/*`)
- No `dynamic` outside generated files?
- No `print()` — only `Logger`?
- No relative imports?
- No `Navigator.push` — only GoRouter?
- All providers `@riverpod` annotated?
- State immutable (`@freezed`)?
- Generated files (`*.g.dart`, `*.freezed.dart`) not manually edited?

### Kiosk rules (`.cursor/rules/android-kiosk/*`)
- `PopScope(canPop: false)` on Payment and Confirmation?
- Idle timeout implemented and timer cancelled in `dispose()`?
- Config read only via `AppConfig`, not `String.fromEnvironment`?
- No hardcoded secrets, sizes, or colours?

### Observability (thesis §4.3)
- Payment events logged with `orderId` at start, success, and failure?
- DB write logged before navigation?
- No card data or PII in log events?

## Reporting

Group findings by: Critical (crashes/data loss/payment failure) → High (security/correctness) → Medium (standards) → Low (style). For each: file:line, what is wrong, how to fix it.
