class WalletModel {
  final String balance;
  final String accountNumber;
  final String lastUpdated;
  final List<TransactionModel> transactions;

  WalletModel({
    required this.balance,
    required this.accountNumber,
    required this.lastUpdated,
    required this.transactions,
  });
}

class TransactionModel {
  final String id;
  final String amount;
  final String type;
  final String method;
  final String date;
  final String status;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.method,
    required this.date,
    required this.status,
  });
}
