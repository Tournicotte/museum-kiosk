package ee.kaasan.museum_kiosk

import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * Debug stub — SumUp SDK is not included in debug builds.
 * StubPaymentService (injected via AppConfig.isDevelopment) handles all payment
 * simulation in dev/emulator mode, so this channel is never called.
 */
class SumUpPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "ee.kaasan.museum_kiosk/sumup")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.error("DEBUG_STUB", "SumUp is not available in debug builds — use StubPaymentService", null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() = Unit
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = Unit
    override fun onDetachedFromActivityForConfigChanges() = Unit
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) = false
}
