enum PaymentStatus {
  idle,
  pinVerified,
  walletInProgress,
  onlineInitializing,
  onlineReady,
  success,
  failure,
  pinVerifying,
}

class PaymentState {
  final String? invoiceId; // currently selected invoice
  final String? paymentUrl;
  final Set<String> selectedFeeIds;
  final PaymentStatus status;
  final String? message; // error messages, if any

  const PaymentState({
    this.invoiceId,
    this.paymentUrl,
    this.selectedFeeIds = const {},
    this.status = PaymentStatus.idle,
    this.message,
  });

  PaymentState copyWith({
    String? invoiceId,
    String? paymentUrl,
    Set<String>? selectedFeeIds,
    PaymentStatus? status,
    String? message,
  }) {
    return PaymentState(
      invoiceId: invoiceId ?? this.invoiceId,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      selectedFeeIds: selectedFeeIds ?? this.selectedFeeIds,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
