enum PaymentStatus { idle, pinVerified, walletInProgress, success, failure, pinVerifying }

class PaymentState {
  final String? invoiceId; // currently selected invoice
  final Set<String> selectedFeeIds;
  final PaymentStatus status;
  final String? message; // error messages, if any

  const PaymentState({
    this.invoiceId,
    this.selectedFeeIds = const {},
    this.status = PaymentStatus.idle,
    this.message,
  });

  PaymentState copyWith({
    String? invoiceId,
    Set<String>? selectedFeeIds,
    PaymentStatus? status,
    String? message,
  }) {
    return PaymentState(
      invoiceId: invoiceId ?? this.invoiceId,
      selectedFeeIds: selectedFeeIds ?? this.selectedFeeIds,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}