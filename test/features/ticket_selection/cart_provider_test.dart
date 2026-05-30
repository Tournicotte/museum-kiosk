import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:museum_kiosk/features/ticket_selection/providers/cart_provider.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProviderContainer container;
  late KioskDatabase db;

  setUp(() {
    db = makeTestDb();
    container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        kioskDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  group('CartNotifier', () {
    test('initial quantity is 1', () {
      expect(container.read(cartProvider), 1);
    });

    test('increment increases quantity by 1', () {
      container.read(cartProvider.notifier).increment();
      expect(container.read(cartProvider), 2);
    });

    test('multiple increments accumulate', () {
      for (var i = 0; i < 4; i++) {
        container.read(cartProvider.notifier).increment();
      }
      expect(container.read(cartProvider), 5);
    });

    test('decrement decreases quantity by 1', () {
      container.read(cartProvider.notifier).increment();
      container.read(cartProvider.notifier).decrement();
      expect(container.read(cartProvider), 1);
    });

    test('decrement does not go below 1', () {
      container.read(cartProvider.notifier).decrement();
      container.read(cartProvider.notifier).decrement();
      expect(container.read(cartProvider), 1);
    });

    test('checkout writes a pending order to DB', () async {
      final orderId = await container.read(cartProvider.notifier).checkout(
            priceCents: 400,
            currency: 'EUR',
            ticketName: 'Museum ticket',
          );

      final order = await (db.select(db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      expect(order.status, 'pending');
      expect(order.totalCents, 400); // qty 1 × €4
    });

    test('checkout totalCents = priceCents × quantity', () async {
      container.read(cartProvider.notifier).increment();
      container.read(cartProvider.notifier).increment(); // qty=3

      final orderId = await container.read(cartProvider.notifier).checkout(
            priceCents: 400,
            currency: 'EUR',
            ticketName: 'Museum ticket',
          );

      final order = await (db.select(db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      expect(order.totalCents, 1200); // 3 × 400
    });

    test('checkout itemsJson records quantity snapshot', () async {
      container.read(cartProvider.notifier).increment(); // qty=2

      final orderId = await container.read(cartProvider.notifier).checkout(
            priceCents: 400,
            currency: 'EUR',
            ticketName: 'Museum ticket',
          );

      final order = await (db.select(db.orders)
            ..where((t) => t.id.equals(orderId)))
          .getSingle();
      final items = (jsonDecode(order.itemsJson) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(items.first['quantity'], 2);
      expect(items.first['priceCents'], 400);
    });

    test('checkout returns a UUID v4', () async {
      final orderId = await container.read(cartProvider.notifier).checkout(
            priceCents: 400,
            currency: 'EUR',
            ticketName: 'Museum ticket',
          );
      expect(orderId, isNotEmpty);
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(orderId),
        isTrue,
      );
    });
  });
}
