import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
import 'package:museum_kiosk/features/admin/models/admin_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_notifier.g.dart';

@riverpod
class Admin extends _$Admin {
  @override
  AdminState build() => const AdminLocked();

  void submitPin(String pin) {
    final config = ref.read(appConfigProvider);
    if (_timingSafeEqual(pin, config.adminPin)) {
      state = const AdminUnlocked();
    } else {
      state = const AdminLocked(errorKey: 'incorrectPin');
    }
  }

  void lock() => state = const AdminLocked();

  static bool _timingSafeEqual(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

@riverpod
Future<List<Order>> todaySales(TodaySalesRef ref) async {
  final db = ref.watch(kioskDatabaseProvider);
  final startOfDay = () {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }();
  final paidOrders =
      await (db.select(db.orders)..where((t) => t.status.equals('paid'))).get();
  return paidOrders.where((o) => !o.createdAt.isBefore(startOfDay)).toList();
}
