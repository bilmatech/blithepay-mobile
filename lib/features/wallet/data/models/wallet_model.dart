class WalletModel {
  final String balance;
  final String address;
  final String name;
  final String tag;
  // final String lastUpdated;
  // final List<TransactionModel> transactions;
  final String ngnBalance;

  WalletModel({
    required this.balance,
    required this.address,
    required this.name,
    required this.tag,
    // required this.lastUpdated,
    // required this.transactions,
    required this.ngnBalance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: json['balance'],
      address: json['address'],
      name: json['name'],
      tag: json['tag'],
      // lastUpdated: json['lastUpdated'],
      // transactions: (json['transactions'] as List)
      //     .map((e) => TransactionModel.fromJson(e))
      //     .toList(),
      ngnBalance: json['ngnBalance'],
    );
  }
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      method: json['method'],
      date: json['date'],
      status: json['status'],
    );
  }
}
