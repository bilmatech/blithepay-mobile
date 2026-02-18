import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';

abstract class WalletTransactionState {}

class WalletTransactionInitial extends WalletTransactionState {}

class WalletTransactionLoading extends WalletTransactionState {}

class WalletTransactionLoaded extends WalletTransactionState {
  final List<WalletTransactionModel> transactions;
  final int? nextPage;
  final bool isFetchingMore;

  WalletTransactionLoaded({
    required this.transactions,
    this.nextPage,
    this.isFetchingMore = false,
  });

  WalletTransactionLoaded copyWith({
    List<WalletTransactionModel>? transactions,
    int? nextPage,
    bool? isFetchingMore,
  }) {
    return WalletTransactionLoaded(
      transactions: transactions ?? this.transactions,
      nextPage: nextPage ?? this.nextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class WalletTransactionError extends WalletTransactionState {
  final String message;
  WalletTransactionError(this.message);
}
