import 'package:blithepay/features/dashboard/presentation/models/dashboard_model.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/wallet_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletTransactionLoading extends WalletState {
  const WalletTransactionLoading();
}

class WalletLoaded extends WalletState {
  final WalletModel wallet;

  const WalletLoaded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

// class WalletTransactionLoaded extends WalletState {
//   final List<WalletTransactionModel> wallet;
//   final int? nextPage;
//   final bool isFetchingMore;

//   const WalletTransactionLoaded({
//     required this.wallet,
//     this.nextPage,
//     this.isFetchingMore = false,
//   });

//   WalletTransactionLoaded copyWith({
//     List<WalletTransactionModel>? wallet,
//     int? nextPage,
//     bool? isFetchingMore,
//   }) {
//     return WalletTransactionLoaded(
//       wallet: wallet ?? this.wallet,
//       nextPage: nextPage ?? this.nextPage,
//       isFetchingMore: isFetchingMore ?? this.isFetchingMore,
//     );
//   }
// }

class TransactionsLoaded extends WalletState {
  final List<TransactionItem> transactions;

  const TransactionsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
