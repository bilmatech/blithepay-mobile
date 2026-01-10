import 'package:equatable/equatable.dart';

abstract class FeesEvent extends Equatable {
  const FeesEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeesEvent extends FeesEvent {
  final String? studentId;

  const FetchFeesEvent({this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class PayFeeEvent extends FeesEvent {
  final String feeId;
  final String amount;
  final String paymentMethod;

  const PayFeeEvent({
    required this.feeId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [feeId, amount, paymentMethod];
}
