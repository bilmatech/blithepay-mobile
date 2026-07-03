abstract class InvoiceEvent {
  const InvoiceEvent();
}

class GetInvoiceEvent extends InvoiceEvent {
  final String studentId;
  final int page;
  final int limit;
  final bool refresh;

  const GetInvoiceEvent({
    required this.studentId,
    this.page = 1,
    this.limit = 20,
    this.refresh = false,
  });

  List<Object?> get props => [studentId, page, limit, refresh];
}

class GetInvoiceByIdEvent extends InvoiceEvent {
  final String invoiceId;

  GetInvoiceByIdEvent({required this.invoiceId});
}

class GetInvoiceByIdViewEvent extends InvoiceEvent {
  final String invoiceId;
  final Set<String>? feesItemIds;

  GetInvoiceByIdViewEvent({required this.invoiceId, this.feesItemIds});
}

class GetInvoiceByIdDownloadEvent extends InvoiceEvent {
  final String invoiceId;

  GetInvoiceByIdDownloadEvent({required this.invoiceId});
}
