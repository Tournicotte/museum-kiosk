import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:museum_kiosk/core/database/database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late KioskDatabase db;

  setUp(() => db = makeTestDb());
  tearDown(() => db.close());

  group('Orders table', () {
    test('insert and retrieve a pending order', () async {
      await db.into(db.orders).insert(
            OrdersCompanion.insert(
              id: 'ord-1',
              status: 'pending',
              totalCents: 400,
              itemsJson: '[]',
            ),
          );

      final rows = await db.select(db.orders).get();
      expect(rows.length, 1);
      expect(rows.first.id, 'ord-1');
      expect(rows.first.status, 'pending');
      expect(rows.first.totalCents, 400);
    });

    test('update status and transaction code on payment success', () async {
      await db.into(db.orders).insert(
            OrdersCompanion.insert(
              id: 'ord-2',
              status: 'pending',
              totalCents: 400,
              itemsJson: '[]',
            ),
          );

      await (db.update(db.orders)..where((t) => t.id.equals('ord-2'))).write(
        OrdersCompanion(
          status: const Value('paid'),
          sumupTransactionCode: const Value('TXN-REAL'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final row = await (db.select(db.orders)
            ..where((t) => t.id.equals('ord-2')))
          .getSingle();
      expect(row.status, 'paid');
      expect(row.sumupTransactionCode, 'TXN-REAL');
    });

    test('update status to error on payment failure', () async {
      await db.into(db.orders).insert(
            OrdersCompanion.insert(
              id: 'ord-3',
              status: 'pending',
              totalCents: 400,
              itemsJson: '[]',
            ),
          );

      await (db.update(db.orders)..where((t) => t.id.equals('ord-3'))).write(
        const OrdersCompanion(status: Value('error')),
      );

      final row = await (db.select(db.orders)
            ..where((t) => t.id.equals('ord-3')))
          .getSingle();
      expect(row.status, 'error');
      expect(row.sumupTransactionCode, isNull);
    });

    test('multiple orders accumulate — append-only audit trail', () async {
      for (var i = 1; i <= 3; i++) {
        await db.into(db.orders).insert(
              OrdersCompanion.insert(
                id: 'ord-$i',
                status: 'paid',
                totalCents: 400 * i,
                itemsJson: '[]',
              ),
            );
      }

      final rows = await db.select(db.orders).get();
      expect(rows.length, 3);
    });
  });

  group('TicketTypes table', () {
    test('insert ticket type and read it back', () async {
      await db.into(db.ticketTypes).insertOnConflictUpdate(
            TicketTypesCompanion(
              id: const Value('tt-1'),
              name: const Value('Museum ticket'),
              description: const Value('General admission'),
              priceCents: const Value(400),
              syncedAt: Value(DateTime.now()),
            ),
          );

      final rows = await db.select(db.ticketTypes).get();
      expect(rows.length, 1);
      expect(rows.first.priceCents, 400);
      expect(rows.first.name, 'Museum ticket');
    });

    test('insertOnConflictUpdate overwrites price — no duplicate rows',
        () async {
      final now = DateTime.now();
      for (final price in [400, 100]) {
        await db.into(db.ticketTypes).insertOnConflictUpdate(
              TicketTypesCompanion(
                id: const Value('tt-2'),
                name: const Value('Museum ticket'),
                description: const Value('General admission'),
                priceCents: Value(price),
                syncedAt: Value(now),
              ),
            );
      }

      final rows = await db.select(db.ticketTypes).get();
      expect(rows.length, 1);
      expect(rows.first.priceCents, 100); // latest value wins
    });
  });
}
