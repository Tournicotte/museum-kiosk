import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/locale/locale_provider.dart';

class AttractScreen extends ConsumerWidget {
  const AttractScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Language selector — top right
            Positioned(
              top: 24,
              right: 24,
              child: _LanguageSelector(currentLocale: currentLocale, ref: ref),
            ),

            // Admin access — top left, unobtrusive
            Positioned(
              top: 24,
              left: 24,
              child: GestureDetector(
                onLongPress: () => context.go(KioskRoutes.admin),
                child: const SizedBox(width: 60, height: 60),
              ),
            ),

            // Main content
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
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
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
