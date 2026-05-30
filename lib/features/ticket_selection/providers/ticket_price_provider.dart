import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticket_price_provider.g.dart';

// Runtime-overridable ticket price. Starts from TICKET_PRICE_CENTS dart-define.
// Admin can change it for special offers (e.g. muuseumöö). Resets on app restart.
@Riverpod(keepAlive: true)
class TicketPrice extends _$TicketPrice {
  @override
  int build() => ref.watch(appConfigProvider).ticketPriceCents;

  void setPrice(int priceCents) {
    if (priceCents > 0) state = priceCents;
  }
}
