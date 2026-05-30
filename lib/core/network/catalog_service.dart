import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:logging/logging.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:museum_kiosk/core/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_service.g.dart';

final _log = Logger('kiosk.catalog');

// Holds the last successful sync timestamp (null = never synced).
// Consumers watch this to display sync status in the admin panel.
@riverpod
class CatalogSync extends _$CatalogSync {
  static const _staleHours = 24;

  @override
  Future<DateTime?> build() async {
    final db = ref.watch(kioskDatabaseProvider);
    final row = await (db.select(db.ticketTypes)..limit(1)).getSingleOrNull();
    return row?.syncedAt;
  }

  bool isStale() {
    final t = state.valueOrNull;
    if (t == null) return true;
    return DateTime.now().difference(t).inHours >= _staleHours;
  }

  /// Fetches ticket types from `GET /v1/ticket-types` and upserts into
  /// the local TicketTypes table.  ticketPriceProvider picks up the new
  /// price automatically via its Drift stream subscription.
  Future<void> sync() async {
    try {
      _log.info('catalog_sync_started');
      final dio = ref.read(apiClientProvider);
      final db = ref.read(kioskDatabaseProvider);

      final response = await dio.get<List<dynamic>>('/v1/ticket-types');
      final types = (response.data ?? <dynamic>[]).cast<Map<String, dynamic>>();

      final now = DateTime.now();
      for (final t in types) {
        final id = t['id'] as String? ?? '';
        if (id.isEmpty) continue;
        await db.into(db.ticketTypes).insertOnConflictUpdate(
              TicketTypesCompanion(
                id: Value(id),
                name: Value(t['name'] as String? ?? ''),
                description: Value(t['description'] as String? ?? ''),
                priceCents: Value(t['price_cents'] as int? ?? 0),
                active: Value(t['active'] as bool? ?? true),
                syncedAt: Value(now),
              ),
            );
      }

      _log.info('catalog_sync_succeeded count=${types.length}');
      state = AsyncData(now);
    } on DioException catch (e) {
      // Network failure — keep the current (cached) state, don't crash.
      _log.warning('catalog_sync_failed: ${e.message}');
    } catch (e, st) {
      _log.severe('catalog_sync_error', e, st);
    }
  }
}
