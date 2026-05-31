import 'dart:async';

import 'package:flutter/material.dart';
import 'package:museum_kiosk/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/locale/locale_provider.dart';
import 'package:museum_kiosk/core/network/catalog_service.dart';

class AttractScreen extends ConsumerStatefulWidget {
  const AttractScreen({super.key});

  @override
  ConsumerState<AttractScreen> createState() => _AttractScreenState();
}

class _AttractScreenState extends ConsumerState<AttractScreen> {
  // 5-tap gesture on the hidden top-right corner opens the admin panel.
  // The tap counter resets after 3 s of inactivity (kiosk-rules.mdc).
  int _adminTaps = 0;
  Timer? _tapResetTimer;

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Sync catalog on every attract-screen appearance.
    // Best-effort: stale data shows until next successful sync.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(catalogSyncProvider.notifier);
      if (notifier.isStale()) notifier.sync();
    });
  }

  void _onHiddenTap() {
    _tapResetTimer?.cancel();
    _adminTaps++;
    if (_adminTaps >= 5) {
      _adminTaps = 0;
      context.go(KioskRoutes.admin);
      return;
    }
    _tapResetTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _adminTaps = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go(KioskRoutes.ticketSelection),
      child: Scaffold(
        body: Stack(
          children: [
            // Hidden admin tap zone — top-right 80×80px, no visual indicator.
            // 5 consecutive taps within 3 s opens the admin panel.
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onHiddenTap,
                child: const SizedBox(width: 80, height: 80),
              ),
            ),

            // Language selector — bottom-right, visible to visitors.
            Positioned(
              bottom: 24,
              right: 24,
              child: _LanguageSelector(
                currentLocale: currentLocale,
                ref: ref,
              ),
            ),

            // Main content — centred.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 96,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    config.museumName,
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.touchToStart,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.currentLocale,
    required this.ref,
  });

  final Locale currentLocale;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final locale in supportedLocales)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _LocaleButton(
              locale: locale,
              isSelected: locale.languageCode == currentLocale.languageCode,
              onTap: () => ref.read(localeProvider.notifier).state = locale,
            ),
          ),
      ],
    );
  }
}

class _LocaleButton extends StatelessWidget {
  const _LocaleButton({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        child: Text(
          locale.languageCode.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
