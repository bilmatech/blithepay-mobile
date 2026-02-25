import 'package:blithepay/features/students/data/models/student_transaction_model.dart';

class PaginatedTransactionModel {
  final List<WalletTransactionModel> transactions;
  final int currentPage;
  final int totalPages;
  final int? nextPage;

  PaginatedTransactionModel({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
  });

  factory PaginatedTransactionModel.fromJson(Map<String, dynamic> json) {
    final mainData = json['data'];
    final List<dynamic> transactionJson = mainData['data'];
    final metadata = mainData['metadata'];

    return PaginatedTransactionModel(
      transactions: transactionJson
          .map((e) => WalletTransactionModel.fromJson(e))
          .toList(),
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }
}

class WalletTransactionModel {
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

  WalletTransactionModel({
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

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
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

class TransactionDetailData {
  final String status;
  final String type;
  final String flow;
  final String transactionAt;
  final String reference;
  final String amount;
  final String fees;
  final String netAmount;
  final String? description;

  TransactionDetailData({
    required this.status,
    required this.type,
    required this.flow,
    required this.transactionAt,
    required this.reference,
    required this.amount,
    required this.fees,
    required this.netAmount,
    this.description,
  });

  factory TransactionDetailData.fromWallet(WalletTransactionModel tx) {
    return TransactionDetailData(
      status: tx.status,
      type: tx.type,
      flow: tx.flow,
      transactionAt: tx.transactionAt,
      reference: tx.reference,
      amount: tx.amount,
      fees: tx.fees,
      netAmount: tx.netAmount,
      description: tx.name,
    );
  }

  factory TransactionDetailData.fromStudent(StudentTransactionModel tx) {
    return TransactionDetailData(
      status: tx.status,
      type: 'Fees',
      flow: '',
      transactionAt: tx.transactionAt.toIso8601String(),
      reference: tx.reference,
      amount: tx.amount,
      fees: (int.parse(tx.vatAmount) + int.parse(tx.latePaymentFee)).toString(),
      netAmount: tx.amount,
      description: tx.description,
    );
  }
}
