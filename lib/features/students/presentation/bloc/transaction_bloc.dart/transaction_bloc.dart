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
    on<GetTransactionsEvent>(_onGetStudentTransactions);
  }

  bool _hasWalletTFetchedOnce = false; // at bloc level
  Future<void> _onGetStudentTransactions(
    GetTransactionsEvent event,
    Emitter<StudentTransactionState> emit,
  ) async {
    final currentState = state;

    List<StudentTransactionModel> oldTransactions = [];

    if (!event.refresh &&
        currentState is StudentTransactionLoaded &&
        event.page > 1) {
      oldTransactions = currentState.studentTransaction;
    }

    final showShimmer = !_hasWalletTFetchedOnce && !event.refresh;

    if (showShimmer) {
      emit(const StudentTransactionLoading());
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (_hasWalletTFetchedOnce && !event.refresh) return;

    try {
      final result = await repository.getStudentTransaction(
        page: event.page,
        limit: event.limit,
        studentId: event.studentId,
      );

      final updatedTransactions = event.refresh
          ? result.transactions
          : [...oldTransactions, ...result.transactions];

      _hasWalletTFetchedOnce = true;

      emit(
        StudentTransactionLoaded(
          studentTransaction: updatedTransactions,
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(StudentTransactionError(message: extractError(e)));

      // Re-emit old state to avoid clearing screen
      if (currentState is StudentTransactionLoaded) {
        emit(currentState);
      }
    }
  }
}
