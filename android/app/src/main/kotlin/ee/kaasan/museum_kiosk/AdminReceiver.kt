package ee.kaasan.museum_kiosk

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

/**
 * Device Owner receiver required for kiosk lock-down.
 *
 * After APK install, activate with:
 *   adb shell dpm set-device-owner ee.kaasan.museum_kiosk/.AdminReceiver
 *
 * MainActivity.enableLockTaskIfDeviceOwner() then calls setLockTaskPackages()
 * and startLockTask() to prevent home/recents escape.
 */
class AdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) = Unit
    override fun onDisabled(context: Context, intent: Intent) = Unit
}
