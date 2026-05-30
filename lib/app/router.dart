import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Routes are stubs until Phase 2 fills in feature screens.
// Constrained flow: Attract → TicketSelection → Payment → Confirmation → Attract.
// No back navigation from Payment or Confirmation (enforced in each screen).

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: KioskRoutes.attract,
    routes: [
      GoRoute(
        path: KioskRoutes.attract,
        builder: (_, __) => const _Stub('Attract'),
      ),
      GoRoute(
        path: KioskRoutes.ticketSelection,
        builder: (_, __) => const _Stub('Ticket Selection'),
      ),
      GoRoute(
        path: KioskRoutes.payment,
        builder: (_, state) => _Stub('Payment — ${state.pathParameters['orderId']}'),
      ),
      GoRoute(
        path: KioskRoutes.confirmation,
        builder: (_, state) => _Stub('Confirmation — ${state.pathParameters['orderId']}'),
      ),
      GoRoute(
        path: KioskRoutes.admin,
        builder: (_, __) => const _Stub('Admin'),
      ),
    ],
  );
});

abstract final class KioskRoutes {
  static const attract = '/';
  static const ticketSelection = '/tickets';
  static const payment = '/payment/:orderId';
  static const confirmation = '/confirmation/:orderId';
  static const admin = '/admin';

  static String paymentFor(String orderId) => '/payment/$orderId';
  static String confirmationFor(String orderId) => '/confirmation/$orderId';
}

// Placeholder until Phase 2 replaces with real feature screens.
class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(label, style: Theme.of(context).textTheme.displayMedium),
        ),
      );
}
