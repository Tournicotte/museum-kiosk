// Sealed error hierarchy — every failure site maps to a named variant.
// Never expose raw exceptions or HTTP bodies to the UI.
sealed class AppError implements Exception {
  const AppError(this.detail);
  final String detail;
}

final class PaymentDeclined extends AppError {
  const PaymentDeclined(super.detail, {required this.sumupCode});
  final String sumupCode;
}

final class PaymentTimeout extends AppError {
  const PaymentTimeout() : super('Payment terminal did not respond in time.');
}

final class PaymentHardwareUnavailable extends AppError {
  const PaymentHardwareUnavailable() : super('Card reader not connected.');
}

final class TicketCatalogUnavailable extends AppError {
  const TicketCatalogUnavailable(super.detail);
}

final class OrderNotFound extends AppError {
  const OrderNotFound(String orderId) : super('Order $orderId not found.');
}

final class NetworkError extends AppError {
  const NetworkError(super.detail, {this.statusCode});
  final int? statusCode;
}

final class DatabaseError extends AppError {
  const DatabaseError(super.detail);
}

final class UnexpectedError extends AppError {
  const UnexpectedError(super.detail, {this.cause});
  final Object? cause;
}
