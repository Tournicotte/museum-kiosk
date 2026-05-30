import 'package:logging/logging.dart';

// Module-level loggers per feature: Logger('kiosk.payment'), etc.
// Never use print() — see dart-code-standards.mdc.
final log = Logger('kiosk');

void setupLogging(String levelName) {
  final level = Level.LEVELS.firstWhere(
    (l) => l.name == levelName.toUpperCase(),
    orElse: () => Level.INFO,
  );

  Logger.root.level = level;
  Logger.root.onRecord.listen((r) {
    final buf = StringBuffer()
      ..write(r.time.toIso8601String())
      ..write(' | ')
      ..write(r.level.name.padRight(7))
      ..write(' | ')
      ..write(r.loggerName)
      ..write(' | ')
      ..write(r.message);

    if (r.error != null) {
      buf
        ..write(' error=')
        ..write(r.error);
    }
    if (r.stackTrace != null) {
      buf
        ..write('\n')
        ..write(r.stackTrace);
    }

    // ignore: avoid_print
    print(buf.toString());
  });
}
