import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticket_price_provider.g.dart';

// Runtime ticket price — sources in priority order:
//   1. Admin manual override (session, resets on restart)
//   2. TicketTypes DB table (written by CatalogSync; updates reactively via stream)
//   3. TICKET_PRICE_CENTS dart-define (build-time default, €4.00)
@Riverpod(keepAlive: true)
class TicketPrice extends _$TicketPrice {
  bool _manualOverride = false;

  @override
  Future<int> build() async {
    _manualOverride = false;
    final db = ref.watch(kioskDatabaseProvider);
    final config = ref.read(appConfigProvider);

    // Subscribe to the first active ticket type from the local DB.
    // When CatalogSync writes new data, the stream fires and this
    // listener updates state automatically — no explicit invalidation needed.
    final stream = (db.select(db.ticketTypes)
          ..where((t) => t.active.equals(true))
          ..limit(1))
        .watchSingleOrNull();

    ref.onDispose(
      stream.listen((row) {
        if (!_manualOverride) {
          final price = row?.priceCents ?? config.ticketPriceCents;
          state = AsyncData(price);
        }
      }).cancel,
    );

    final initial = await stream.first;
    return initial?.priceCents ?? config.ticketPriceCents;
  }

  /// Admin override — takes priority over DB and dart-define for this session.
  void setPrice(int priceCents) {
    if (priceCents > 0) {
      _manualOverride = true;
      state = AsyncData(priceCents);
    }
  }
}
