import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:museum_kiosk/core/errors/app_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:museum_kiosk/core/config/app_config.dart';

// Constrained Operation Selection (sumup-payments.mdc):
// charge() is the only permitted operation. No caller may bypass this interface.
abstract interface class PaymentService {
  Future<PaymentResult> charge({
    required String orderId,
    required int amountCents,
    required String currency,
    required String title,
  });
}

final class PaymentResult {
  const PaymentResult({
    required this.success,
    this.transactionCode,
    this.errorDetail,
  });

  final bool success;
  final String? transactionCode;
  final String? errorDetail;
}

// SumUp via platform channel. Kotlin host: android/.../SumUpPlugin.kt (Phase 3).
final class SumUpPaymentService implements PaymentService {
  static const _channel = MethodChannel('ee.kaasan.museum_kiosk/sumup');
  final _log = Logger('kiosk.payment.sumup');

  @override
  Future<PaymentResult> charge({
    required String orderId,
    required int amountCents,
    required String currency,
    required String title,
  }) async {
    _log.info(
        'charge_started orderId=$orderId amountCents=$amountCents currency=$currency');

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('charge', {
        'orderId': orderId,
        'amountCents': amountCents,
        'currency': currency,
        'title': title,
      });

      if (result == null) throw const PaymentHardwareUnavailable();

      final success = result['success'] as bool? ?? false;
      if (success) {
        _log.info(
            'charge_succeeded orderId=$orderId transactionCode=${result['transactionCode']}');
      } else {
        _log.warning(
            'charge_failed orderId=$orderId detail=${result['errorDetail']}');
      }

      return PaymentResult(
        success: success,
        transactionCode: result['transactionCode'] as String?,
        errorDetail: result['errorDetail'] as String?,
      );
    } on PlatformException catch (e, st) {
      _log.severe('charge_exception orderId=$orderId', e, st);
      return switch (e.code) {
        'TIMEOUT' => throw const PaymentTimeout(),
        'UNAVAILABLE' => throw const PaymentHardwareUnavailable(),
        _ => throw PaymentDeclined(e.message ?? 'Unknown', sumupCode: e.code),
      };
    }
  }
}

// Dev stub — 2s fake successful charge. Injected via ProviderScope override.
final class StubPaymentService implements PaymentService {
  final _log = Logger('kiosk.payment.stub');

  @override
  Future<PaymentResult> charge({
    required String orderId,
    required int amountCents,
    required String currency,
    required String title,
  }) async {
    _log.info('stub_charge_started orderId=$orderId amountCents=$amountCents');
    await Future<void>.delayed(const Duration(seconds: 2));
    _log.info(
        'stub_charge_succeeded orderId=$orderId transactionCode=STUB-TXN-001');
    return const PaymentResult(success: true, transactionCode: 'STUB-TXN-001');
  }
}

// Resolved from config: SumUp in production, stub in development.
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.isProduction ? SumUpPaymentService() : StubPaymentService();
});
