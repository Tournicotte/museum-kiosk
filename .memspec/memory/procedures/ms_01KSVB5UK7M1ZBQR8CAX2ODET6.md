---
id: ms_01KSVB5UK7M1ZBQR8CAX2ODET6
type: procedure
state: active
confidence: 0.8
created: '2026-05-30T00:00:00.000Z'
source: claude
tags:
  - deploy
  - tablet
  - adb
decay_after: '2026-08-28T00:00:00.000Z'
---
# Build and deploy APK to Android tablet

1. Build release APK with all required --dart-define values:
   ```
   flutter build apk \
     --dart-define=ENV=production \
     --dart-define=MUSEUM_NAME="Museum Name" \
     --dart-define=SUMUP_AFFILIATE_KEY=<key> \
     --dart-define=ADMIN_PIN=<pin> \
     --dart-define=IDLE_TIMEOUT_SECONDS=60 \
     --dart-define=BACKEND_URL=https://...
   ```
2. Connect tablet via USB. Verify ADB sees device: `adb devices`
3. Install: `adb install build/app/outputs/apk/release/app-release.apk`
4. (First install only) Set as launcher and lock down:
   ```
   adb shell dpm set-device-owner ee.kaasan.museum_kiosk/.AdminReceiver
   ```
   Then call DevicePolicyManager.setLockTaskPackages() from within the app admin panel.
5. Verify: app launches, attract screen shows, SumUp reader pairs via Bluetooth, admin PIN works.

Note: Affiliate key and admin PIN are never committed to source. Store them in a password manager. See security.mdc — secrets management.
