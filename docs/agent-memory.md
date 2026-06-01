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

### Mistake: leaving orphaned l10n keys after removing the widget that used them

**Wrong**:
Removing a `Text(l10n.foo)` (e.g. an AppBar title or a transaction-ref line) but leaving
`"foo"` in `lib/l10n/app_*.arb`. Neither `flutter gen-l10n` nor `flutter analyze` flags an
unused ARB key, and `analyze` will not flag stale getters in the generated `app_localizations*.dart`
either — so the dead string silently survives.

**Correct**:
When you delete the last usage of an l10n key, also delete it from **all** locale `.arb` files
(including any `@key` metadata block in the template `app_et.arb`), then run `flutter gen-l10n`
to refresh the generated getters. Confirm with:
`grep -rn "l10n\.<key>" lib --include='*.dart' | grep -v lib/l10n` → expect zero hits.
Same principle for now-unused constructor params plumbed through GoRouter `extra`: remove the
param, the router's `extra` extraction, and the `context.go(..., extra: ...)` call together.
