import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletDataEvent extends WalletEvent {
  final bool forceRefresh;

  const FetchWalletDataEvent({this.forceRefresh = false});
}



class FundWalletEvent extends WalletEvent {
  final String amount;
  final String paymentMethod;

  const FundWalletEvent({required this.amount, required this.paymentMethod});

  @override
  List<Object?> get props => [amount, paymentMethod];
}
