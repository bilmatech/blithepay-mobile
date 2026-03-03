abstract class PaymentEvent {}

class InitializePayment extends PaymentEvent {
  final String invoiceId;
  final Set<String> selectedFeeIds;

  InitializePayment({required this.invoiceId, required this.selectedFeeIds});
}

class VerifyPin extends PaymentEvent {
  final String pin;
  VerifyPin(this.pin);
}

class PayWithWallet extends PaymentEvent {}

class PaymentFailed extends PaymentEvent {
  final String message;
  PaymentFailed(this.message);
}

class ResetPayment extends PaymentEvent {}
