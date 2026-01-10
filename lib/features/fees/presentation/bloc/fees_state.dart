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

class FeesError extends FeesState {
  final String message;

  const FeesError(this.message);

  @override
  List<Object?> get props => [message];
}
