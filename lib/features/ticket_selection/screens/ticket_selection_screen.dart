import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:logging/logging.dart';
import 'package:museum_kiosk/core/widgets/idle_detector.dart';
import 'package:museum_kiosk/features/ticket_selection/providers/cart_provider.dart';

final _log = Logger('kiosk.ticket_selection');

class TicketSelectionScreen extends ConsumerWidget {
  const TicketSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final quantity = ref.watch(cartProvider);
    final totalCents = config.ticketPriceCents * quantity;
    final theme = Theme.of(context);

    return IdleDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.selectTickets),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.ticketSingle,
                              style: theme.textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.ticketSingleDesc,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withAlpha(180),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _QuantityButton(
                                  icon: Icons.remove,
                                  onPressed: quantity > 1
                                      ? () => ref
                                          .read(cartProvider.notifier)
                                          .decrement()
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: Text(
                                    '$quantity',
                                    style: theme.textTheme.displaySmall,
                                  ),
                                ),
                                _QuantityButton(
                                  icon: Icons.add,
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .increment(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              _formatCents(totalCents,
                                  Localizations.localeOf(context).toString()),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(KioskRoutes.attract),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 32),
                  FilledButton.icon(
                    onPressed: () => _onPay(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      priceCents: config.ticketPriceCents,
                      totalCents: totalCents,
                      quantity: quantity,
                    ),
                    icon: const Icon(Icons.credit_card),
                    label: Text(l10n.payByCard),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPay({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required int priceCents,
    required int totalCents,
    required int quantity,
  }) async {
    try {
      final orderId = await ref.read(cartProvider.notifier).checkout(
            priceCents: priceCents,
            currency: 'EUR',
            ticketName: l10n.ticketSingle,
          );
      if (!context.mounted) return;
      context.go(
        KioskRoutes.paymentFor(orderId),
        extra: <String, Object?>{'amountCents': totalCents, 'currency': 'EUR'},
      );
    } catch (e, st) {
      _log.severe('checkout_failed', e, st);
    }
  }

  static String _formatCents(int cents, String locale) {
    final amount = cents / 100.0;
    return NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 2,
    ).format(amount);
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 32),
      ),
    );
  }
}
