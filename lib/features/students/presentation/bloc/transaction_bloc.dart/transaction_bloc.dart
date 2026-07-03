import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/students/data/models/student_transaction_model.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_event.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentTransactionsBloc
    extends Bloc<StudentTransactionEvent, StudentTransactionState> {
  final StudentsRepository repository;

  StudentTransactionsBloc({required this.repository})
    : super(const StudentTransactionInitial()) {
    on<GetPaymentHistoryEvent>(_onGetStudentTransactions);
  }

  Future<void> _onGetStudentTransactions(
    GetPaymentHistoryEvent event,
    Emitter<StudentTransactionState> emit,
  ) async {
    final currentState = state;

    // Prevent duplicate pagination calls
    if (currentState is StudentTransactionLoaded &&
        currentState.isFetchingMore &&
        !event.refresh) {
      return;
    }

    List<StudentTransactionModel> oldTransactions = [];

    if (!event.refresh &&
        currentState is StudentTransactionLoaded &&
        event.page > 1) {
      oldTransactions = currentState.studentTransaction;

      // Emit fetching-more state
      emit(currentState.copyWith(isFetchingMore: true));
    } else if (event.page == 1 && !event.refresh) {
      emit(const StudentTransactionLoading());
    }

    try {
      final result = await repository.getStudentTransaction(
        page: event.page,
        limit: event.limit,
        studentId: event.studentId,
      );

      emit(
        StudentTransactionLoaded(
          studentTransaction: event.refresh
              ? result.transactions
              : [...oldTransactions, ...result.transactions],
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      if (currentState is StudentTransactionLoaded) {
        emit(currentState.copyWith(isFetchingMore: false));
      } else {
        emit(StudentTransactionError(message: extractError(e)));
      }
    }
  }
}
