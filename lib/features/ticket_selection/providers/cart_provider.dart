import 'dart:convert';

import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'cart_provider.g.dart';

@riverpod
class Cart extends _$Cart {
  @override
  int build() => 1;

  void increment() => state = state + 1;

  void decrement() {
    if (state > 1) state = state - 1;
  }

  Future<String> checkout({
    required int priceCents,
    required String currency,
    required String ticketName,
  }) async {
    final quantity = state;
    final orderId = const Uuid().v4();
    final db = ref.read(kioskDatabaseProvider);
    final itemsJson = jsonEncode(<Map<String, Object?>>[
      <String, Object?>{
        'ticketTypeId': 'museum_ticket',
        'name': ticketName,
        'priceCents': priceCents,
        'quantity': quantity,
      },
    ]);
    await db.into(db.orders).insert(OrdersCompanion.insert(
          id: orderId,
          status: 'pending',
          totalCents: priceCents * quantity,
          itemsJson: itemsJson,
        ));
    return orderId;
  }
}
