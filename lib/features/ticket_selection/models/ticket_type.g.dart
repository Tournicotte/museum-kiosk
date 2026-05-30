// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TicketTypeImpl _$$TicketTypeImplFromJson(Map<String, dynamic> json) =>
    _$TicketTypeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      currency: json['currency'] as String? ?? 'EUR',
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$$TicketTypeImplToJson(_$TicketTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'priceCents': instance.priceCents,
      'currency': instance.currency,
      'active': instance.active,
    };
