# Agent Memory

Persistent log of mistakes and their fixes, per `.cursor/rules/common/agent-memory.mdc`.
Read this before starting work; append corrections after fixing a mistake or deprecation.

Keep entries general and reusable — not one-off, file-specific details.

## Format

```markdown
### Mistake: [Short Description]
**Wrong**:
[incorrect code or logic]

**Correct**:
[corrected code or logic]
```

---

<!-- Add entries below. -->

### Mistake: Unused database.dart import when only database_provider.dart is needed

**Wrong**:
```dart
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/database/database_provider.dart';
```
Used both when only calling `db.select(...)` on the `KioskDatabase` instance.

**Correct**:
```dart
import 'package:museum_kiosk/core/database/database_provider.dart';
```
`database_provider.dart` transitively exposes all Drift-generated types through the database part file. Import `database.dart` explicitly only when you need to name a Drift companion or row type directly (e.g., `OrdersCompanion`, `TicketTypesCompanion`).

### Mistake: isBiggerOrEqualValue / & operator on Drift GeneratedColumn in where()

**Wrong**:
```dart
..where((t) => t.status.equals('paid') & t.createdAt.isBiggerOrEqualValue(startOfDay))
```
`isBiggerOrEqualValue` and the `&` operator are not available on `GeneratedColumn` unless `package:drift/drift.dart` is explicitly imported in the calling file.

**Correct**:
Filter in Dart after a simpler DB query, or add `import 'package:drift/drift.dart';` explicitly. For small datasets (daily orders), Dart-side filtering is acceptable:
```dart
final allPaid = await (db.select(db.orders)..where((t) => t.status.equals('paid'))).get();
return allPaid.where((o) => !o.createdAt.isBefore(startOfDay)).toList();
```
