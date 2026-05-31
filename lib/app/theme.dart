import 'package:flutter/material.dart';

// Kiosk theme: min 72px touch targets, high contrast, no hover states.
ThemeData kioskTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A3A5C),
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: base,
    useMaterial3: true,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(180, 72),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(160, 64),
        textStyle: const TextStyle(fontSize: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(120, 64),
        textStyle: const TextStyle(fontSize: 20),
      ),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 22),
      bodyMedium: TextStyle(fontSize: 18),
      labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    ),
  );
}
