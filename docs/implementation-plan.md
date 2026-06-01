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

## Phase 1 — Core infrastructure ✅
- [x] `pubspec.yaml` — full dependency set (Riverpod, GoRouter, Drift, Freezed, logging, wakelock_plus)
- [x] `analysis_options.yaml` — strict analysis rules
- [x] `lib/core/config/app_config.dart` — `AppConfig.fromEnvironment()`
- [x] `lib/core/logging/logger.dart` — structured logger setup
- [x] `lib/core/errors/app_error.dart` — sealed `AppError` hierarchy
- [x] `lib/core/database/database.dart` — Drift schema (`Orders`, `TicketTypes`)
- [x] `lib/core/payment/payment_service.dart` — `PaymentService` interface + `SumUpPaymentService` + `StubPaymentService`
- [x] `lib/app/theme.dart` — kiosk theme (large touch targets, high contrast)
- [x] `lib/app/router.dart` — GoRouter with `KioskRoutes` constants

## Phase 2 — Feature screens ✅
- [x] `lib/features/attract/` — idle screen, language selector (ET default), long-press admin entry
- [x] `lib/features/ticket_selection/` — single ticket type + quantity selector, cart provider, DB order creation
- [x] `lib/features/payment/` — SumUp charge flow, `PopScope(canPop: false)`, retry on failure
- [x] `lib/features/confirmation/` — success receipt, 15s auto-return timer
- [x] `lib/features/admin/` — PIN gate (constant-time compare), today's sales dashboard
- [x] Idle timeout across all non-attract screens
- [x] `TICKET_PRICE_CENTS` dart-define; single ticket type via l10n strings

## Phase 3 — Android native ✅
- [x] `AndroidManifest.xml` — singleTask, sensorLandscape, HOME+DEFAULT intent, showWhenLocked,
      turnScreenOn, Bluetooth permissions (BLUETOOTH/ADMIN legacy + SCAN/CONNECT API31+,
      ACCESS_FINE_LOCATION), INTERNET/ACCESS_NETWORK_STATE
- [x] `SumUpPlugin.kt` — FlutterPlugin + ActivityAware + ActivityResultListener;
      one permitted method (charge); affiliateKey via BuildConfig.SUMUP_AFFILIATE_KEY;
      skips SumUp success/failure screens; maps all result codes to Dart contract
- [x] `MainActivity.kt` — registers SumUpPlugin via configureFlutterEngine
- [x] `android/app/build.gradle` — dart-define extraction → BuildConfig, minSdk=21,
      SumUp SDK dependency, buildFeatures.buildConfig=true
- [x] `android/build.gradle` — SumUp Maven repository added
- [x] `attract_screen.dart` — fixed admin access: 5-tap hidden top-right 80×80px zone
      (3s reset timer, no visual indicator); language selector moved to bottom-right

## Phase 4 — Backend integration ✅
- [x] `lib/core/network/api_client.dart` — keepAlive Dio; 10s connect / 15s receive timeouts;
      `X-Kiosk-Id` header from `KIOSK_ID` dart-define; request/response/error logging
- [x] `lib/core/network/catalog_service.dart` — `CatalogSync` AsyncNotifier;
      `GET /v1/ticket-types` → upsert `TicketTypes` table; DioException silently kept as
      cached state; `isStale()` helper (>24h threshold); auto-triggered on attract screen
      when stale, manually by admin "Sync catalog" button
- [x] `lib/core/network/receipt_service.dart` — `ReceiptService.sendReceipt()`;
      `POST /v1/orders/{id}/receipt`; best-effort (never throws, never blocks confirmation)
- [x] `ticketPriceProvider` promoted to `AsyncNotifier<int>` — builds from Drift stream
      on `TicketTypes` table; reactive to catalog sync writes; `_manualOverride` flag
      preserves admin price changes; falls back to `TICKET_PRICE_CENTS` dart-define
- [x] `AppConfig` gains `KIOSK_ID` dart-define (default `kiosk-01`)
- [x] Confirmation screen fires receipt webhook on init (post-frame, non-blocking)
- [x] Attract screen triggers stale-catalog sync on each appearance
- [x] Admin dashboard: sync status row (last synced time, stale warning icon,
      "Syncing…" indicator, "Sync catalog" button); price resolves from async provider

## Phase 5 — Hardening, deployment, and CI/CD ✅

### Tests (24 passing)
- [x] `test/helpers/test_helpers.dart` — `testConfig`, `MockPaymentService`, `makeTestDb()`
- [x] `test/core/database/database_test.dart` — order insert/update/status; ticket-type upsert/no-duplicate
- [x] `test/core/payment/payment_notifier_test.dart` — success, success=false, Declined, Timeout,
      Unavailable; DB row updated to paid/error correctly
- [x] `test/features/ticket_selection/cart_provider_test.dart` — increment/decrement/floor;
      checkout total, itemsJson snapshot, UUID v4 format
- [x] `KioskDatabase.forTesting()` constructor using `NativeDatabase.memory()`

### Signing & hardening
- [x] `android/app/build.gradle` — env-var-driven keystore (`KEYSTORE_PATH`, `KEYSTORE_PASSWORD`,
      `KEY_ALIAS`, `KEY_PASSWORD`); falls back to debug keystore locally; `minifyEnabled`,
      `shrinkResources`, proguard enabled for release builds
- [x] `android/app/proguard-rules.pro` — keep rules for SumUp SDK, Kotlin, Flutter, Drift

### Device Owner lock-down
- [x] `AdminReceiver.kt` — `DeviceAdminReceiver` subclass; activates via
      `adb shell dpm set-device-owner ee.kaasan.museum_kiosk/.AdminReceiver`
- [x] `res/xml/device_admin.xml` — device-admin policy declaration
- [x] `AndroidManifest.xml` — `AdminReceiver` registered with `BIND_DEVICE_ADMIN` permission;
      `android:lockTaskMode="if_whitelisted"` on the activity
- [x] `MainActivity.kt` — `enableLockTaskIfDeviceOwner()` calls `setLockTaskPackages()` +
      `startLockTask()` when Device Owner is active; no-op in development

### CI/CD — GitHub Actions + Oracle Cloud Free Tier
- [x] `.github/workflows/ci.yml` — quality gate on every push/PR: `flutter pub get`,
      build_runner codegen check, `flutter analyze`, `flutter test`; GitHub-hosted ubuntu runner
- [x] `.github/workflows/build.yml` — signed APK on push to main: decodes keystore from
      `KEYSTORE_BASE64` secret, builds with all production dart-defines, uploads versioned +
      `latest` APK to Oracle Object Storage; self-hosted `oracle-arm` runner; keystore wiped after
- [x] `docs/tablet-provisioning.md` — keystore generation, GitHub Secrets table, Oracle Cloud
      ARM VM provisioning steps, GitHub Actions runner registration, first install, Device Owner
      activation, APK update procedure

## Phase 6 — UI hardening & polish ✅
- [x] Attract screen: pure-black background; OLED burn-in drift is now **idle-gated** —
      content only drifts after 3 min untouched (`_idleBeforeDrift`), and any touch
      (`Listener.onPointerDown`) recentres it immediately, so it never moves while a visitor
      interacts (e.g. switching language). Amplitude reduced to ±6 px X / ±4 px Y, 45 s cycle,
      resting at the origin (sin/sin Lissajous)
- [x] Attract screen: enlarged the "touch to start" text (headlineMedium) and the language
      buttons (h28/v18 padding, titleLarge), language selector at 0.8 opacity for tappability
- [x] Attract screen shows localized `l10n.museumDisplayName` (ET/EN/DE) instead of the
      `MUSEUM_NAME` dart-define; the dart-define value remains the MaterialApp title + log field
- [x] Admin: removed the redundant "Today's sales" refresh icon — `todaySalesProvider` is
      re-queried on every admin entry and no sale can occur while the panel is open, so the only
      meaningful refresh is "Sync catalog" (pulls ticket types/price from the backend)
- [x] Ticket selection: removed AppBar (card already carries the heading) for a cleaner kiosk look
- [x] Confirmation: removed the SumUp transaction-ref line shown to visitors (the code is still
      persisted in `Orders.sumupTransactionCode` and sent via the receipt webhook)
- [x] Dead-code cleanup from the above: dropped orphaned l10n keys `selectTickets` and `ref`,
      and the now-unused `transactionCode` param plumbed Payment → router → Confirmation
      (regenerated l10n; analyze clean; format clean; 24 tests pass)
