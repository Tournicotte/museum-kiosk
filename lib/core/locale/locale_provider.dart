import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Default locale is Estonian. User can switch on the attract screen.
final localeProvider = StateProvider<Locale>((ref) => const Locale('et'));

const supportedLocales = [
  Locale('et'), // Estonian — primary
  Locale('en'), // English
];
