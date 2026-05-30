import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:museum_kiosk/features/admin/screens/admin_screen.dart';
import 'package:museum_kiosk/features/attract/screens/attract_screen.dart';
import 'package:museum_kiosk/features/confirmation/screens/confirmation_screen.dart';
import 'package:museum_kiosk/features/payment/screens/payment_screen.dart';
import 'package:museum_kiosk/features/ticket_selection/screens/ticket_selection_screen.dart';

// Constrained flow: Attract → TicketSelection → Payment → Confirmation → Attract.
// Payment and Confirmation enforce PopScope(canPop: false) — no back navigation.

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: KioskRoutes.attract,
    routes: [
      GoRoute(
        path: KioskRoutes.attract,
        builder: (_, __) => const AttractScreen(),
      ),
      GoRoute(
        path: KioskRoutes.ticketSelection,
        builder: (_, __) => const TicketSelectionScreen(),
      ),
      GoRoute(
        path: KioskRoutes.payment,
        builder: (_, state) {
          final orderId = state.pathParameters['orderId']!;
          final extra = state.extra as Map<String, Object?>?;
          final amountCents = extra?['amountCents'] as int? ?? 0;
          final currency = extra?['currency'] as String? ?? 'EUR';
          return PaymentScreen(
            orderId: orderId,
            amountCents: amountCents,
            currency: currency,
          );
        },
      ),
      GoRoute(
        path: KioskRoutes.confirmation,
        builder: (_, state) {
          final orderId = state.pathParameters['orderId']!;
          final extra = state.extra as Map<String, Object?>?;
          final transactionCode = extra?['transactionCode'] as String?;
          return ConfirmationScreen(
            orderId: orderId,
            transactionCode: transactionCode,
          );
        },
      ),
      GoRoute(
        path: KioskRoutes.admin,
        builder: (_, __) => const AdminScreen(),
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
