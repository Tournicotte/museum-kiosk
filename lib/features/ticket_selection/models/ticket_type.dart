import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_type.freezed.dart';
part 'ticket_type.g.dart';

@freezed
class TicketType with _$TicketType {
  const factory TicketType({
    required String id,
    required String name,
    required String description,
    required int priceCents,
    @Default('EUR') String currency,
    @Default(true) bool active,
  }) = _TicketType;

  factory TicketType.fromJson(Map<String, dynamic> json) =>
      _$TicketTypeFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required TicketType ticketType,
    @Default(1) int quantity,
  }) = _CartItem;

  const CartItem._();

  int get subtotalCents => ticketType.priceCents * quantity;
}
