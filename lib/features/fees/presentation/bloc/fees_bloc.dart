import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/fee_model.dart';
import 'fees_event.dart';
import 'fees_state.dart';

class FeesBloc extends Bloc<FeesEvent, FeesState> {
  FeesBloc() : super(const FeesInitial()) {
    on<FetchFeesEvent>(_onFetchFees);
    on<PayFeeEvent>(_onPayFee);
  }

  Future<void> _onFetchFees(FetchFeesEvent event, Emitter<FeesState> emit) async {
    try {
      emit(const FeesLoading());
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));
      final mockFees = [
        FeeModel(
          id: '1',
          studentName: 'Adebayo Oluwaferanmi',
          studentId: '7yty5675dmn',
          feeName: 'Tuition Fee',
          amount: 'N130,000',
          dueDate: '11/12/25',
          status: 'Pending',
        ),
        FeeModel(
          id: '2',
          studentName: 'Adebayo Oluwaferanmi',
          studentId: '7yty5675dmn',
          feeName: 'School Uniform',
          amount: 'N60,000',
          dueDate: '11/12/25',
          status: 'Pending',
        ),
      ];
      emit(FeesLoaded(mockFees));
    } catch (e) {
      emit(FeesError(e.toString()));
    }
  }

  Future<void> _onPayFee(PayFeeEvent event, Emitter<FeesState> emit) async {
    try {
      emit(const FeePaymentLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(const FeePaymentSuccess(
        message: 'Fee paid successfully',
        transactionId: '98yuy6434678gfe54',
      ));
    } catch (e) {
      emit(FeesError(e.toString()));
    }
  }
}
