import 'package:drift/drift.dart' show Value;
import 'package:logging/logging.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:museum_kiosk/core/errors/app_error.dart';
import 'package:museum_kiosk/core/payment/payment_service.dart';
import 'package:museum_kiosk/features/payment/models/payment_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_notifier.g.dart';

final _log = Logger('kiosk.payment');

@riverpod
class Payment extends _$Payment {
  @override
  PaymentState build(String orderId) => const PaymentIdle();

  Future<void> start({
    required int amountCents,
    required String currency,
  }) async {
    state = const PaymentProcessing();
    _log.info(
        'charge_started orderId=$orderId amountCents=$amountCents currency=$currency');
    try {
      final service = ref.read(paymentServiceProvider);
      final result = await service.charge(
        orderId: orderId,
        amountCents: amountCents,
        currency: currency,
        title: 'Museum ticket',
      );
      if (result.success) {
        _log.info(
          'charge_succeeded orderId=$orderId transactionCode=${result.transactionCode}',
        );
        await _updateOrder('paid', result.transactionCode);
        state = PaymentSuccess(transactionCode: result.transactionCode);
      } else {
        _log.warning(
            'charge_failed orderId=$orderId detail=${result.errorDetail}');
        await _updateOrder('error', null);
        state = PaymentFailed(detail: result.errorDetail ?? 'unknown');
      }
    } on PaymentDeclined catch (e) {
      _log.warning(
          'charge_failed orderId=$orderId sumupCode=${e.sumupCode} detail=${e.detail}');
      await _updateOrder('error', null);
      state = PaymentFailed(detail: e.detail);
    } on PaymentTimeout catch (_) {
      _log.warning('charge_failed orderId=$orderId sumupCode=TIMEOUT');
      await _updateOrder('error', null);
      state = const PaymentFailed(detail: 'timeout');
    } on PaymentHardwareUnavailable catch (_) {
      _log.warning('charge_failed orderId=$orderId sumupCode=UNAVAILABLE');
      await _updateOrder('error', null);
      state = const PaymentFailed(detail: 'unavailable');
    } catch (e, st) {
      _log.severe('charge_exception orderId=$orderId', e, st);
      await _updateOrder('error', null);
      state = PaymentFailed(detail: e.toString());
    }
  }

  Future<void> _updateOrder(String status, String? transactionCode) async {
    try {
      final db = ref.read(kioskDatabaseProvider);
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          status: Value(status),
          sumupTransactionCode: Value(transactionCode),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, st) {
      _log.severe('order_update_failed orderId=$orderId', e, st);
    }
  }
}
