import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/fees/data/repositories/fees_repository.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_event.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final FeesRepository repository; // use your existing repo

  PaymentBloc({required this.repository}) : super(const PaymentState()) {
    on<InitializePayment>(_onInitialize);
    on<VerifyPin>(_onVerifyPin);
    on<PayWithWallet>(_onPayWithWallet);
    on<PaymentFailed>(_onPaymentFailed);
    on<ResetPayment>(_onReset);
  }

  void _onInitialize(InitializePayment event, Emitter<PaymentState> emit) {
    emit(
      state.copyWith(
        invoiceId: event.invoiceId,
        selectedFeeIds: event.selectedFeeIds,
        status: PaymentStatus.idle,
        message: null,
      ),
    );
  }

  Future<void> _onVerifyPin(VerifyPin event, Emitter<PaymentState> emit) async {
    emit(state.copyWith(status: PaymentStatus.pinVerifying));

    try {
      // If invalid, this throws
      await repository.verifyPin(event.pin);

      if (state.invoiceId == null || state.selectedFeeIds.isEmpty) {
        emit(
          state.copyWith(
            status: PaymentStatus.failure,
            message: 'Payment not initialized',
          ),
        );
        return;
      }

      // PIN OK → continue to wallet payment
      add(PayWithWallet());
    } catch (e) {
      emit(
        state.copyWith(status: PaymentStatus.failure, message: extractError(e)),
      );
    }
  }

  Future<void> _onPayWithWallet(
    PayWithWallet event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.walletInProgress));

    try {
      await repository.payWithWallet(
        state.invoiceId!,
        state.selectedFeeIds.toList(),
      );

      emit(state.copyWith(status: PaymentStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: PaymentStatus.failure, message: extractError(e)),
      );
    }
  }

  void _onPaymentFailed(PaymentFailed event, Emitter<PaymentState> emit) {
    emit(state.copyWith(status: PaymentStatus.failure, message: event.message));
  }

  void _onReset(ResetPayment event, Emitter<PaymentState> emit) {
    emit(const PaymentState());
  }
}
