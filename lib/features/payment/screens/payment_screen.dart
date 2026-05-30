import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/features/payment/models/payment_state.dart';
import 'package:museum_kiosk/features/payment/providers/payment_notifier.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amountCents,
    required this.currency,
  });

  final String orderId;
  final int amountCents;
  final String currency;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider(widget.orderId).notifier).start(
            amountCents: widget.amountCents,
            currency: widget.currency,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final paymentState = ref.watch(paymentProvider(widget.orderId));

    ref.listen(paymentProvider(widget.orderId), (_, next) {
      if (next is PaymentSuccess) {
        context.go(
          KioskRoutes.confirmationFor(widget.orderId),
          extra: <String, Object?>{'transactionCode': next.transactionCode},
        );
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: switch (paymentState) {
            PaymentIdle() || PaymentProcessing() => _ProcessingView(l10n: l10n),
            PaymentSuccess() => const SizedBox.shrink(),
            PaymentFailed() => _FailedView(
                l10n: l10n,
                onRetry: () => ref
                    .read(paymentProvider(widget.orderId).notifier)
                    .start(
                        amountCents: widget.amountCents,
                        currency: widget.currency),
                onCancel: () => context.go(KioskRoutes.attract),
              ),
          },
        ),
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(strokeWidth: 6),
        const SizedBox(height: 40),
        Text(
          l10n.processingPayment,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.doNotRemoveCard,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.l10n,
    required this.onRetry,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.paymentFailed,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onCancel,
                child: Text(l10n.startAgain),
              ),
              const SizedBox(width: 32),
              FilledButton(
                onPressed: onRetry,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
