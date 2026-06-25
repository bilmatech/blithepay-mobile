enum TransactionStatus {
  PENDING,
  SUCCESS,
  REVERSED,
  FAILED,
}

enum TransactionFlow { inflow, outflow }

enum TransactionType {
  DEPOSIT,
  WITHDRAWAL,
  TRANSFER,
  REVERSAL,
}

class TransactionModel {
  final String name;
  final String desc;
  final DateTime transactionAt;
  final String amount;
  final String netAmount;
  final String reference;
  final TransactionStatus status;
  final TransactionFlow flow;
  final TransactionType type;
  final String icon; // emoji or asset path
  final double fees;

  const TransactionModel({
    required this.name,
    this.desc = '',
    required this.transactionAt,
    required this.amount,
    required this.netAmount,
    required this.reference,
    required this.status,
    required this.flow,
    required this.type,
    required this.icon,
    required this.fees,
  });

  // -------------------------
  // Factory from Map
  // -------------------------
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      name: map['name'] ?? '',
      transactionAt: _parseDate(map['date']),
      amount: map['amount'] ?? '',
      netAmount: map['netAmount'] ?? map['amount'] ?? '',
      reference: map['reference'] ?? '',
      status: _parseStatus(map['status']),
      flow: _parseFlow(map['flow']),
      type: _parseType(map['type']),
      icon: map['icon'] ?? '',
      fees: (map['fees'] ?? 0).toDouble(),
    );
  }

  // -------------------------
  // Convert to Map
  // -------------------------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'transactionAt': transactionAt.toIso8601String(),
      'amount': amount,
      'netAmount': netAmount,
      'reference': reference,
      'status': status.name,
      'flow': flow.name,
      'type': type.name,
      'icon': icon,
      'fees': fees,
    };
  }

  // -------------------------
  // Helpers
  // -------------------------
  static DateTime _parseDate(String? date) {
    if (date == null) return DateTime.now();

    try {
      return DateTime.parse(date);
    } catch (_) {
      return DateTime.now(); // fallback for your mixed formats
    }
  }

  static TransactionStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
      case 'SUCCESSFUL':
        return TransactionStatus.SUCCESS;
      case 'FAILED':
        return TransactionStatus.FAILED;
      case 'REVERSED':
        return TransactionStatus.REVERSED;
      case 'PENDING':
      default:
        return TransactionStatus.PENDING;
    }
  }

  static TransactionFlow _parseFlow(String? flow) {
    switch (flow?.toLowerCase()) {
      case 'inflow':
        return TransactionFlow.inflow;
      case 'outflow':
      default:
        return TransactionFlow.outflow;
    }
  }

  static TransactionType _parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'DEPOSIT':
        return TransactionType.DEPOSIT;
      case 'WITHDRAWAL':
        return TransactionType.WITHDRAWAL;
      case 'TRANSFER':
        return TransactionType.TRANSFER;
      case 'REVERSAL':
        return TransactionType.REVERSAL;
      default:
        return TransactionType.TRANSFER;
    }
  }
}
