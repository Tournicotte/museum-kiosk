import 'package:museum_kiosk/core/database/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
KioskDatabase kioskDatabase(KioskDatabaseRef ref) => KioskDatabase();
