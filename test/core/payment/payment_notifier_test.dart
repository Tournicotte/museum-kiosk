import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:museum_kiosk/core/errors/app_error.dart';
import 'package:museum_kiosk/core/payment/payment_service.dart';
import 'package:museum_kiosk/features/payment/models/payment_state.dart';
import 'package:museum_kiosk/features/payment/providers/payment_notifier.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProviderContainer container;
  late MockPaymentService mockService;
  late KioskDatabase db;

  // Inserts a pending order so _updateOrder() has a row to update.
  Future<void> seedOrder(String orderId) => db.into(db.orders).insert(
        OrdersCompanion.insert(
          id: orderId,
          status: 'pending',
          totalCents: 400,
          itemsJson: '[]',
        ),
      );

  setUp(() {
    mockService = MockPaymentService();
    db = makeTestDb();
    container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        paymentServiceProvider.overrideWithValue(mockService),
        kioskDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  group('PaymentNotifier', () {
    test('initial state is PaymentIdle', () {
      expect(container.read(paymentProvider('o-0')), isA<PaymentIdle>());
    });

    test('start — successful charge → PaymentSuccess with transactionCode',
        () async {
      await seedOrder('o-1');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenAnswer(
        (_) async =>
            const PaymentResult(success: true, transactionCode: 'TXN-001'),
      );

      await container
          .read(paymentProvider('o-1').notifier)
          .start(amountCents: 400, currency: 'EUR');

      final state = container.read(paymentProvider('o-1'));
      expect(state, isA<PaymentSuccess>());
      expect((state as PaymentSuccess).transactionCode, 'TXN-001');
    });

    test('start — service returns success=false → PaymentFailed', () async {
      await seedOrder('o-2');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenAnswer(
        (_) async => const PaymentResult(
            success: false, errorDetail: 'Insufficient funds'),
      );

      await container
          .read(paymentProvider('o-2').notifier)
          .start(amountCents: 400, currency: 'EUR');

      expect(container.read(paymentProvider('o-2')), isA<PaymentFailed>());
    });

    test('start — PaymentDeclined thrown → PaymentFailed', () async {
      await seedOrder('o-3');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenThrow(
          const PaymentDeclined('Card declined', sumupCode: 'DECLINED'));

      await container
          .read(paymentProvider('o-3').notifier)
          .start(amountCents: 400, currency: 'EUR');

      expect(container.read(paymentProvider('o-3')), isA<PaymentFailed>());
    });

    test('start — PaymentTimeout thrown → PaymentFailed', () async {
      await seedOrder('o-4');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenThrow(const PaymentTimeout());

      await container
          .read(paymentProvider('o-4').notifier)
          .start(amountCents: 400, currency: 'EUR');

      expect(container.read(paymentProvider('o-4')), isA<PaymentFailed>());
    });

    test('start — PaymentHardwareUnavailable thrown → PaymentFailed', () async {
      await seedOrder('o-5');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenThrow(const PaymentHardwareUnavailable());

      await container
          .read(paymentProvider('o-5').notifier)
          .start(amountCents: 400, currency: 'EUR');

      expect(container.read(paymentProvider('o-5')), isA<PaymentFailed>());
    });

    test('order row updated to paid + transactionCode on success', () async {
      await seedOrder('o-6');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenAnswer(
        (_) async =>
            const PaymentResult(success: true, transactionCode: 'TXN-DB'),
      );

      await container
          .read(paymentProvider('o-6').notifier)
          .start(amountCents: 400, currency: 'EUR');

      final row = await (db.select(db.orders)..where((t) => t.id.equals('o-6')))
          .getSingle();
      expect(row.status, 'paid');
      expect(row.sumupTransactionCode, 'TXN-DB');
    });

    test('order row updated to error on timeout', () async {
      await seedOrder('o-7');
      when(
        () => mockService.charge(
          orderId: any(named: 'orderId'),
          amountCents: any(named: 'amountCents'),
          currency: any(named: 'currency'),
          title: any(named: 'title'),
        ),
      ).thenThrow(const PaymentTimeout());

      await container
          .read(paymentProvider('o-7').notifier)
          .start(amountCents: 400, currency: 'EUR');

      final row = await (db.select(db.orders)..where((t) => t.id.equals('o-7')))
          .getSingle();
      expect(row.status, 'error');
    });
  });
}
