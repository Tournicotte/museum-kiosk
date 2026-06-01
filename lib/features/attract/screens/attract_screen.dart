import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/core/locale/locale_provider.dart';
import 'package:museum_kiosk/core/network/catalog_service.dart';
import 'package:museum_kiosk/l10n/app_localizations.dart';

class AttractScreen extends ConsumerStatefulWidget {
  const AttractScreen({super.key});

  @override
  ConsumerState<AttractScreen> createState() => _AttractScreenState();
}

class _AttractScreenState extends ConsumerState<AttractScreen>
    with SingleTickerProviderStateMixin {
  // Hidden admin zone: 5 taps in the TOP-RIGHT 80×80px corner within 3 s.
  int _adminTaps = 0;
  Timer? _tapResetTimer;

  // Burn-in protection: a slow, subtle pixel-shift drift of the main content,
  // but ONLY after the kiosk has sat untouched for [_idleBeforeDrift]. Any
  // touch cancels the drift and snaps the content back to centre, so visitors
  // never see it move while they interact (e.g. while switching language).
  static const _idleBeforeDrift = Duration(minutes: 3);
  late final AnimationController _burnInController;
  Timer? _idleTimer;
  bool _drifting = false;

  @override
  void initState() {
    super.initState();
    _burnInController = AnimationController(
      duration: const Duration(seconds: 45),
      vsync: this,
    );
    _idleTimer = Timer(_idleBeforeDrift, _startDrift);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(catalogSyncProvider.notifier);
      if (notifier.isStale()) notifier.sync();
    });
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    _idleTimer?.cancel();
    _burnInController.dispose();
    super.dispose();
  }

  // Begin drifting once the screen has been idle long enough.
  void _startDrift() {
    if (!mounted) return;
    setState(() => _drifting = true);
    _burnInController
      ..reset()
      ..repeat();
  }

  // Any touch: stop drifting, recentre the content, restart the idle countdown.
  void _onInteraction() {
    _idleTimer?.cancel();
    if (_drifting) {
      setState(() => _drifting = false);
      _burnInController
        ..stop()
        ..reset();
    }
    _idleTimer = Timer(_idleBeforeDrift, _startDrift);
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
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onInteraction(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(KioskRoutes.ticketSelection),
        child: Scaffold(
          // Pure black — OLED pixels are fully OFF, eliminating burn-in risk
          // for the screen that runs 95% of the day.
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── Hidden admin zone — top-RIGHT corner, 80×80 px ──────────
              // Tap 5 times within 3 s. Inner GD wins the gesture arena so
              // the main-screen tap does NOT interfere.
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onHiddenTap,
                  child: const SizedBox(width: 80, height: 80),
                ),
              ),

              // ── Language selector — bottom-right ─────────────────────────
              // Slightly dimmed (0.8) to reduce burn-in from the static buttons
              // while staying large and clearly tappable.
              Positioned(
                bottom: 24,
                right: 24,
                child: Opacity(
                  opacity: 0.8,
                  child: _LanguageSelector(
                    currentLocale: currentLocale,
                    ref: ref,
                  ),
                ),
              ),

              // ── Main content — slow pixel-shift drift ────────────────────
              AnimatedBuilder(
                animation: _burnInController,
                builder: (_, child) {
                  if (!_drifting) return child!;
                  // Subtle Lissajous drift that rests at the origin (value 0 → 0,0).
                  final t = _burnInController.value * 2 * math.pi;
                  return Transform.translate(
                    offset: Offset(
                      math.sin(t) * 6,
                      math.sin(t * 0.7) * 4,
                    ),
                    child: child,
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 96,
                        color: theme.colorScheme.primary.withAlpha(200),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.museumDisplayName,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white.withAlpha(220),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.touchToStart,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white.withAlpha(180),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            padding: const EdgeInsets.only(left: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary, width: 2.5),
        ),
        child: Text(
          locale.languageCode.toUpperCase(),
          style: theme.textTheme.titleLarge?.copyWith(
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
