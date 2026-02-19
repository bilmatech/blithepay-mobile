class PaginatedInvoiceModel {
  final List<InvoiceModel> invoices;
  final int currentPage;
  final int totalPages;
  final int? nextPage;

  PaginatedInvoiceModel({
    required this.invoices,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
  });

  factory PaginatedInvoiceModel.fromJson(Map<String, dynamic> json) {
    final mainData = json['data'];
    final List<dynamic> invoicesJson = mainData['data'];
    final metadata = mainData['metadata'];

    return PaginatedInvoiceModel(
      invoices: invoicesJson
          .map((e) => InvoiceModel.fromJson(e))
          .toList(),
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }
}

class InvoiceModel {
  final String id;
  final String name;
  final String walletId;
  final String amount;
  final String fees;
  final String netAmount;
  final String reference;
  final String type;
  final String flow;
  final String transactionAt;
  final String processedAt;
  final String? description;
  final String status;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  InvoiceModel({
    required this.id,
    required this.name,
    required this.walletId,
    required this.amount,
    required this.fees,
    required this.netAmount,
    required this.reference,
    required this.type,
    required this.flow,
    required this.transactionAt,
    required this.processedAt,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      name: json['name'],
      walletId: json['walletId'],
      amount: json['amount'],
      fees: json['fees'],
      netAmount: json['netAmount'],
      reference: json['reference'],
      type: json['type'],
      flow: json['flow'],
      transactionAt: json['transactionAt'],
      processedAt: json['processedAt'],
      description: json['desc'],
      status: json['status'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  /// Optional helper for UI
  bool get isCredit => flow.toLowerCase() == 'inflow';

  /// Optional helper to get display amount with sign
  String get formattedAmount => isCredit ? '+$amount' : '-$amount';
}
