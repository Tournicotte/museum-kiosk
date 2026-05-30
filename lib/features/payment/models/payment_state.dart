sealed class PaymentState {
  const PaymentState();
}

final class PaymentIdle extends PaymentState {
  const PaymentIdle();
}

final class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

final class PaymentSuccess extends PaymentState {
  const PaymentSuccess({this.transactionCode});
  final String? transactionCode;
}

final class PaymentFailed extends PaymentState {
  const PaymentFailed({required this.detail});
  final String detail;
}
