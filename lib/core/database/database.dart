import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// Orders — written before SumUp charge, updated on outcome.
// Append-only audit trail; never deleted.
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()(); // pending | paid | cancelled | error
  IntColumn get totalCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get itemsJson => text()(); // JSON snapshot of line items
  TextColumn get sumupTransactionCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// TicketTypes — seeded from backend, cached for offline display.
class TicketTypes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get priceCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Orders, TicketTypes])
class KioskDatabase extends _$KioskDatabase {
  KioskDatabase() : super(_openConnection());

  // In-memory instance for unit tests — isolated, no file I/O.
  KioskDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'museum_kiosk');
}
