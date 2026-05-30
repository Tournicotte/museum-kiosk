import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/app/theme.dart';
import 'package:museum_kiosk/core/config/app_config.dart';

class KioskApp extends ConsumerWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: config.museumName,
      theme: kioskTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
