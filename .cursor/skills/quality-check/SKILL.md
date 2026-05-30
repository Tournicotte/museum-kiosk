---
name: quality-check
description: >-
  Runs the pre-completion quality orchestrator after substantive work:
  simplifier, security-check, code-review, and validation. Use when the user
  asks to finish work, run quality checks, wrap up a task, or says quality-check.
---

# Quality check (finish-work orchestrator)

Use this when wrapping work that changed code or configuration. If nothing substantive changed, skip invented cleanup and answer normally.

## Orchestrator (run in order)

1. Check whether this turn changed code or configuration. If it did not, do not invent cleanup work.

2. If files changed, simplify the touched files — remove duplication, unnecessary complexity, and over-engineering while preserving exact behaviour.

3. Run the **security-check** skill on the changed files — payment security, kiosk escape paths, secrets exposure, PII in logs.

4. Run a full **code-review** skill pass against `.cursor/rules/**` and project conventions.

5. Apply clear findings for correctness, security, standards, and maintainability. Ask before broad refactors, behaviour changes, or ambiguous tradeoffs.

6. Validation — run in order:
   ```bash
   dart run build_runner build --delete-conflicting-outputs   # if any @riverpod/@freezed changed
   dart format --output=none --set-exit-if-changed lib/ test/
   flutter analyze
   flutter test
   ```
   Fix issues introduced by the work when the fix is clear and local.

7. Keep the final response concise: summarise simplification, security fixes, review fixes, validation results, and any unresolved findings.
