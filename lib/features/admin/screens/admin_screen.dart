import 'package:flutter/material.dart';
import 'package:museum_kiosk/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:museum_kiosk/app/router.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/widgets/idle_detector.dart';
import 'package:museum_kiosk/features/admin/models/admin_state.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/network/catalog_service.dart';
import 'package:museum_kiosk/features/admin/providers/admin_notifier.dart';
import 'package:museum_kiosk/features/ticket_selection/providers/ticket_price_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final l10n = AppLocalizations.of(context);

    return IdleDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminTitle),
          automaticallyImplyLeading: false,
          actions: [
            if (adminState is AdminUnlocked)
              IconButton(
                icon: const Icon(Icons.lock_outline),
                onPressed: () => ref.read(adminProvider.notifier).lock(),
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go(KioskRoutes.attract),
            ),
          ],
        ),
        body: switch (adminState) {
          AdminLocked(errorKey: final errorKey) =>
            _PinEntryView(errorKey: errorKey),
          AdminUnlocked() => const _DashboardView(),
        },
      ),
    );
  }
}

class _PinEntryView extends ConsumerStatefulWidget {
  const _PinEntryView({this.errorKey});

  final String? errorKey;

  @override
  ConsumerState<_PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends ConsumerState<_PinEntryView> {
  static const _pinLength = 4;

  String _pin = '';

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() => _pin = _pin + digit);
    if (_pin.length == _pinLength) {
      ref.read(adminProvider.notifier).submitPin(_pin);
      setState(() => _pin = '');
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.enterPin, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(60),
                      ),
                    ),
                  ),
                ),
              ),

              if (widget.errorKey != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.incorrectPin,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],

              const SizedBox(height: 32),

              // Numeric keypad
              _NumericKeypad(onDigit: _onDigit, onDelete: _onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({required this.onDigit, required this.onDelete});

  final void Function(String) onDigit;
  final VoidCallback onDelete;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 80);
            return Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 80,
                height: 80,
                child: FilledButton(
                  onPressed: key == 'del' ? onDelete : () => onDigit(key),
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: key == 'del'
                      ? const Icon(Icons.backspace_outlined, size: 28)
                      : Text(
                          key,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final salesAsync = ref.watch(todaySalesProvider);
    final syncState = ref.watch(catalogSyncProvider);
    final config = ref.read(appConfigProvider);

    // Resolve price: DB/stream value while available, config default as fallback.
    final priceCents =
        ref.watch(ticketPriceProvider).valueOrNull ?? config.ticketPriceCents;

    final lastSynced = syncState.valueOrNull;
    final isSyncing = syncState.isLoading;
    final isStale = syncState.whenOrNull(
          data: (t) => t == null || DateTime.now().difference(t).inHours >= 24,
        ) ??
        false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Ticket price control ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              Text(l10n.ticketPrice, style: theme.textTheme.titleMedium),
              const SizedBox(width: 12),
              Text(
                _formatCents(priceCents),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _PriceDialog(
                    currentCents: ref.read(ticketPriceProvider).valueOrNull ??
                        config.ticketPriceCents,
                    onConfirm: (cents) =>
                        ref.read(ticketPriceProvider.notifier).setPrice(cents),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: Text(l10n.changePrice),
              ),
            ],
          ),
        ),

        // ── Catalog sync row ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            children: [
              if (isSyncing)
                Text(
                  l10n.syncingNow,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                )
              else if (lastSynced != null)
                Text(
                  l10n.lastSynced(
                    DateFormat('dd.MM HH:mm').format(lastSynced),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isStale
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withAlpha(160),
                  ),
                )
              else
                Text(
                  l10n.neverSynced,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              if (isStale && !isSyncing) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
              ],
              const Spacer(),
              TextButton.icon(
                onPressed: isSyncing
                    ? null
                    : () => ref.read(catalogSyncProvider.notifier).sync(),
                icon: const Icon(Icons.sync, size: 18),
                label: Text(l10n.syncCatalog),
              ),
            ],
          ),
        ),
        const Divider(height: 28),

        // ── Today's sales ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Text(l10n.todaySales, style: theme.textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(todaySalesProvider),
              ),
            ],
          ),
        ),
        Expanded(
          child: salesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Icon(Icons.error_outline, size: 48)),
            data: (orders) => _SalesList(orders: orders),
          ),
        ),
      ],
    );
  }

  static String _formatCents(int cents) {
    return NumberFormat.currency(symbol: '€', decimalDigits: 2)
        .format(cents / 100.0);
  }
}

class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.currentCents, required this.onConfirm});

  final int currentCents;
  final void Function(int cents) onConfirm;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  String _euros = '';

  void _onDigit(String d) {
    if (_euros.length >= 3) return;
    setState(() => _euros = _euros + d);
  }

  void _onDelete() {
    if (_euros.isEmpty) return;
    setState(() => _euros = _euros.substring(0, _euros.length - 1));
  }

  String _displayPrice() {
    if (_euros.isEmpty) {
      return '€${(widget.currentCents / 100).toStringAsFixed(2)}';
    }
    return '€$_euros.00';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canConfirm = _euros.isNotEmpty && (_euros != '0');

    return AlertDialog(
      title: Text(l10n.newPriceEuros),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _displayPrice(),
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _NumericKeypad(onDigit: _onDigit, onDelete: _onDelete),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: canConfirm
              ? () {
                  widget.onConfirm((int.parse(_euros)) * 100);
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(l10n.done),
        ),
      ],
    );
  }
}

class _SalesList extends StatelessWidget {
  const _SalesList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Text(
          '—',
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(100),
          ),
        ),
      );
    }

    final totalCents = orders.fold<int>(0, (sum, o) => sum + o.totalCents);
    final totalFormatted = _formatCents(totalCents);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                '${orders.length} kv',
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              Text(
                totalFormatted,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final order = orders[i];
              final time = DateFormat('HH:mm').format(order.createdAt);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(time, style: theme.textTheme.bodyMedium),
                trailing: Text(
                  _formatCents(order.totalCents),
                  style: theme.textTheme.bodyMedium,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _formatCents(int cents) {
    return NumberFormat.currency(symbol: '€', decimalDigits: 2)
        .format(cents / 100.0);
  }
}
