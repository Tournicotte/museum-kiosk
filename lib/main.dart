import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:museum_kiosk/app/app.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/logging/logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiosk: landscape only, full-screen immersive, screen always on.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await WakelockPlus.enable();

  final config = AppConfig.fromEnvironment();
  setupLogging(config.logLevel);
  log.info('kiosk_start env=${config.environment} museum=${config.museumName}');

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const KioskApp(),
    ),
  );
}
