import 'package:blithepay/features/fees/data/models/payment_data.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/fee_model.dart';

abstract class FeesState extends Equatable {
  const FeesState();

  @override
  List<Object?> get props => [];
}

class FeesInitial extends FeesState {
  const FeesInitial();
}

class FeesLoading extends FeesState {
  const FeesLoading();
}

class FeesByIdLoaded extends FeesState {
  final List<FeeBreakdownModel> fees;

  const FeesByIdLoaded(this.fees);

  @override
  List<Object?> get props => [fees];
}

class FeesLoaded extends FeesState {
  final List<FeeModel> fees;

  const FeesLoaded(this.fees);

  @override
  List<Object?> get props => [fees];
}

class FeePaymentLoading extends FeesState {
  const FeePaymentLoading();
}

class FeePaymentSuccess extends FeesState {
  final String message;
  final String transactionId;

  const FeePaymentSuccess({required this.message, required this.transactionId});

  @override
  List<Object?> get props => [message, transactionId];
}

class PinVerified extends FeesState {
  const PinVerified();
}

class WalletPaymentSuccess extends FeesState {
  final WalletPaymentData data;
  const WalletPaymentSuccess(this.data);
}

class FeesError extends FeesState {
  final String message;

  const FeesError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletPaymentInProgress extends FeesState {
  const WalletPaymentInProgress();
}

class WalletPaymentFailure extends FeesState {
  final String message;
  const WalletPaymentFailure(this.message);
}

class PinVerificationFailure extends FeesState {
  final String message;
  const PinVerificationFailure(this.message);
}