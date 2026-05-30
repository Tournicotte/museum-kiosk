import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/app/router.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.orderId,
    this.transactionCode,
  });

  final String orderId;
  final String? transactionCode;

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  static const _autoReturnSeconds = 15;

  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _autoReturnSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _goHome();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    _timer?.cancel();
    if (mounted) context.go(KioskRoutes.attract);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 96,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.paymentSuccessful,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.transactionCode != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    '${l10n.ref}: ${widget.transactionCode}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 48),
                Text(
                  l10n.returningIn(_secondsLeft),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _goHome,
                  child: Text(l10n.done),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
