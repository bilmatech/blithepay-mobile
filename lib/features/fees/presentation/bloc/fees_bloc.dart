import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/fees/data/repositories/fees_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'fees_event.dart';
import 'fees_state.dart';

class FeesBloc extends Bloc<FeesEvent, FeesState> {
  final FeesRepository repository;

  FeesBloc({required this.repository}) : super(const FeesInitial()) {
    on<FetchFeesByIdEvent>(_onFeesById);
    on<VerifyPinEvent>(_onVerifyPin);
    on<PayWithWalletEvent>(_onPayWithWallet);

    on<FetchFeesEvent>(_onFetchFees);
    on<PayFeeEvent>(_onPayFee);
  }

  Future<void> _onFeesById(
    FetchFeesByIdEvent event,
    Emitter<FeesState> emit,
  ) async {
    final currentState = state;

    // Only show loading spinner if we don't already have data
    if (currentState is! FeesByIdLoaded) {
      emit(const FeesLoading());
    }

    try {
      final fees = await repository.getFeesById(
        event.invoice.feeId,
        event.studentCode,
      );

      emit(FeesByIdLoaded(fees.feeBreakdowns));
    } catch (e) {
      // Preserve previous data if it exists
      if (currentState is FeesByIdLoaded) {
        emit(currentState);
      } else {
        emit(FeesError(extractError(e)));
      }
    }
  }

  Future<void> _onVerifyPin(
    VerifyPinEvent event,
    Emitter<FeesState> emit,
  ) async {
    emit(const FeesLoading());
    try {
      await repository.verifyPin(event.pin);
      emit(const PinVerified());
    } catch (e) {
      emit(FeesError(extractError(e)));
    }
  }

Future<void> _onPayWithWallet(
  PayWithWalletEvent event,
  Emitter<FeesState> emit,
) async {
  emit(const WalletPaymentInProgress());

  try {
    final result = await repository.payWithWallet(
      event.invoiceId,
      event.feeItemIds,
    );

    emit(WalletPaymentSuccess(result));
  } catch (e) {
    emit(
      WalletPaymentFailure(extractError(e)),
    );
  }
}

  Future<void> _onFetchFees(
    FetchFeesEvent event,
    Emitter<FeesState> emit,
  ) async {
    try {
      emit(const FeesLoading());
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));
      // final mockFees = [
      //   FeeModel(
      //     id: '1',
      //     name: 'Adebayo Oluwaferanmi',
      //     latePaymentFee: 'N130,000',
      //     dueAt: DateTime.now(),
      //     classModel: null,
      //     term: null,
      //     academicSession: null,
      //   ),
      //   FeeModel(
      //     id: '2',
      //     name: 'Adebayo Oluwaferanmi',
      //     dueAt: DateTime.now(),
      //     latePaymentFee: '',
      //     classModel: null,
      //     term: null,
      //     academicSession: null,
      //   ),
      // ];

      //  emit(FeesLoaded(mockFees));
    } catch (e) {
      emit(FeesError(e.toString()));
    }
  }

  Future<void> _onPayFee(PayFeeEvent event, Emitter<FeesState> emit) async {
    try {
      emit(const FeePaymentLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(
        const FeePaymentSuccess(
          message: 'Fee paid successfully',
          transactionId: '98yuy6434678gfe54',
        ),
      );
    } catch (e) {
      emit(FeesError(e.toString()));
    }
  }
}
