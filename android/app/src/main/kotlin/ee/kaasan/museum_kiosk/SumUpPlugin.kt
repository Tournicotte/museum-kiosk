package ee.kaasan.museum_kiosk

import android.app.Activity
import android.content.Intent
import com.sumup.merchant.api.SumUpAPI
import com.sumup.merchant.api.SumUpPaymentRequest
import com.sumup.merchant.api.models.SumUpCurrency
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.math.BigDecimal

/**
 * SumUpPlugin — Constrained Operation Selection Pattern (sumup-payments.mdc).
 *
 * Exposes exactly one operation: charge(). Any other method call is rejected.
 * The Dart layer (SumUpPaymentService) is the only permitted caller.
 */
class SumUpPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {

    private var channel: MethodChannel? = null
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    companion object {
        private const val CHANNEL = "ee.kaasan.museum_kiosk/sumup"
        private const val SUMUP_REQUEST_CODE = 0x5B17  // arbitrary, unique to this plugin
        private val ALLOWED_OPERATIONS = setOf("charge")
    }

    // ── FlutterPlugin ────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    // ── MethodCallHandler ────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method !in ALLOWED_OPERATIONS) {
            result.error("UNKNOWN_METHOD", "Method '${call.method}' is not permitted", null)
            return
        }
        when (call.method) {
            "charge" -> handleCharge(call, result)
        }
    }

    private fun handleCharge(call: MethodCall, result: Result) {
        val act = activity
        if (act == null) {
            result.error("UNAVAILABLE", "No Android activity available", null)
            return
        }
        if (pendingResult != null) {
            result.error("UNAVAILABLE", "A payment is already in progress", null)
            return
        }

        val orderId = call.argument<String>("orderId") ?: ""
        val amountCents = call.argument<Int>("amountCents") ?: 0
        val currency = call.argument<String>("currency") ?: "EUR"
        val title = call.argument<String>("title") ?: ""

        val sumupCurrency = when (currency) {
            "EUR" -> SumUpCurrency.EUR
            "GBP" -> SumUpCurrency.GBP
            "USD" -> SumUpCurrency.USD
            else  -> SumUpCurrency.EUR
        }

        val request = SumUpPaymentRequest.builder()
            .total(BigDecimal.valueOf(amountCents.toLong(), 2))
            .currency(sumupCurrency)
            .title(title)
            .foreignTransactionId(orderId)
            .skipSuccessScreen()
            .skipFailedScreen()
            .build()

        pendingResult = result
        SumUpAPI.openPaymentActivity(act, request, SUMUP_REQUEST_CODE)
    }

    // ── ActivityResultListener ───────────────────────────────────────────────

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != SUMUP_REQUEST_CODE) return false

        val pending = pendingResult ?: return true
        pendingResult = null

        if (data == null) {
            pending.error("UNAVAILABLE", "SumUp returned no result", null)
            return true
        }

        val code = data.getIntExtra(SumUpAPI.Response.RESULT_CODE, -1)
        val txCode = data.getStringExtra(SumUpAPI.Response.TX_CODE)
        val message = data.getStringExtra(SumUpAPI.Response.MESSAGE)

        when (code) {
            SumUpAPI.Response.ResultCode.SUCCESSFUL -> {
                pending.success(
                    mapOf("success" to true, "transactionCode" to txCode, "errorDetail" to null)
                )
            }
            SumUpAPI.Response.ResultCode.ERROR_TRANSACTION_TIMED_OUT -> {
                pending.error("TIMEOUT", "Payment timed out", null)
            }
            SumUpAPI.Response.ResultCode.ERROR_NOT_LOGGED_IN -> {
                pending.error("UNAVAILABLE", "SumUp: not logged in", null)
            }
            SumUpAPI.Response.ResultCode.ERROR_TRANSACTION_CANCELLED,
            SumUpAPI.Response.ResultCode.ERROR_TRANSACTION_FAILED -> {
                pending.success(
                    mapOf(
                        "success" to false,
                        "transactionCode" to null,
                        "errorDetail" to (message ?: "Transaction failed"),
                    )
                )
            }
            else -> {
                pending.error("DECLINED", message ?: "Unknown error (code=$code)", null)
            }
        }
        return true
    }

    // ── ActivityAware ────────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)

        // Initialise SumUp SDK with the affiliate key baked in at build time.
        // Key is empty in development (StubPaymentService is used instead).
        val affiliateKey = BuildConfig.SUMUP_AFFILIATE_KEY
        if (affiliateKey.isNotEmpty()) {
            SumUpAPI.setup(binding.activity.application, affiliateKey)
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
