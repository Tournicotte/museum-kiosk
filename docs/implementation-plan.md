# Implementation Plan

Single source of truth for project status and roadmap. Update after completing milestones.

---

## Phase 0 — Project foundation ✅
- [x] Flutter scaffold (`ee.kaasan.museum_kiosk`, Android only)
- [x] Git repository initialised
- [x] `.cursor/rules/**` — full MDC rule set
- [x] `.cursor/skills/` — quality-check, security-check, code-review
- [x] `.cursor/hooks/` — secrets protection hook
- [x] `.cursor/commands/` + `.cursor/prompts/`
- [x] `.memspec/` — structured memory, config, initial facts/decisions/procedures
- [x] `CLAUDE.md` — agent entry point
- [x] `docs/agent-memory.md`, `docs/implementation-plan.md`
- [x] `.mcp.json` — memspec MCP server

## Phase 1 — Core infrastructure
- [ ] `pubspec.yaml` — full dependency set (Riverpod, GoRouter, Drift, Freezed, logging, wakelock_plus)
- [ ] `analysis_options.yaml` — strict analysis rules
- [ ] `lib/core/config/app_config.dart` — `AppConfig.fromEnvironment()`
- [ ] `lib/core/logging/logger.dart` — structured logger setup
- [ ] `lib/core/errors/app_error.dart` — sealed `AppError` hierarchy
- [ ] `lib/core/database/database.dart` — Drift schema (`Orders`, `TicketTypes`)
- [ ] `lib/core/payment/sumup_payment_service.dart` — `PaymentService` interface + `SumUpPaymentService` + `StubPaymentService`
- [ ] `lib/app/theme.dart` — kiosk theme (large touch targets, high contrast)
- [ ] `lib/app/router.dart` — GoRouter with `KioskRoutes` constants

## Phase 2 — Feature screens
- [ ] `lib/features/attract/` — idle screen, hidden admin tap target
- [ ] `lib/features/ticket_selection/` — catalog display, cart provider
- [ ] `lib/features/payment/` — SumUp charge flow, `PopScope(canPop: false)`
- [ ] `lib/features/confirmation/` — success receipt, 15s auto-return
- [ ] `lib/features/admin/` — PIN gate, read-only sales summary, catalog sync trigger
- [ ] Idle timeout across all non-attract screens

## Phase 3 — Android native
- [ ] `AndroidManifest.xml` — kiosk manifest (HOME intent, singleTask, landscape, BT permissions)
- [ ] `android/.../SumUpPlugin.kt` — platform channel, `charge` method only
- [ ] `build.gradle` — SumUp AAR dependency (`com.sumup-merchant.api:android-sdk:4.2.0`)

## Phase 4 — Backend integration
- [ ] Backend sync: `GET /v1/ticket-types` → update local `TicketTypes` table
- [ ] Receipt webhook: `POST /v1/orders/{id}/receipt` after confirmed payment
- [ ] Offline fallback: serve cached ticket types if sync fails
- [ ] Admin panel: show today's sales from local DB

## Phase 5 — Hardening, deployment, and CI/CD
- [ ] Tablet provisioning procedure documented in `.memspec/procedures/`
- [ ] Device Owner lock-down (`AdminReceiver`, `setLockTaskPackages`)
- [ ] Signing config for release APK (keystore, env secrets)
- [ ] `flutter test` coverage for payment provider, cart provider, DB layer

### CI/CD — Oracle Cloud Free Tier
- [ ] GitHub Actions: `flutter analyze` + `flutter test` on every PR (free, public repo)
- [ ] Oracle Cloud ARM VM (Ampere A1, always-free): self-hosted Actions runner for APK builds
- [ ] Oracle Object Storage (always-free): store signed APK artifacts per build
- [ ] Simple APK distribution endpoint: tablets pull latest from Object Storage URL
- [ ] Provision Oracle VM: install Flutter, set up runner as systemd service
- [ ] Secrets in GitHub: `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `SUMUP_AFFILIATE_KEY`, `ADMIN_PIN`

**Note:** Codemagic is worth evaluating as alternative — generous Flutter-specific free tier, no infra to manage. Decision in `.memspec/decisions/ms_01KSVB6VL8N2ACRS9DBY3PEFT7.md`.
