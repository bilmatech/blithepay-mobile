import 'package:blithepay/features/students/data/models/student_transaction_model.dart';

abstract class StudentTransactionState {
  const StudentTransactionState();
}

class StudentTransactionInitial extends StudentTransactionState {
  const StudentTransactionInitial();
}

class StudentTransactionLoaded extends StudentTransactionState {
  final List<StudentTransactionModel> studentTransaction;
  final int? nextPage;
  final bool isFetchingMore;

  const StudentTransactionLoaded({
    required this.studentTransaction,
    this.nextPage,
    this.isFetchingMore = false,
  });

  StudentTransactionLoaded copyWith({
    String? studentId,
    List<StudentTransactionModel>? studentTransaction,
    int? nextPage,
    bool? isFetchingMore,
  }) {
    return StudentTransactionLoaded(
      studentTransaction: studentTransaction ?? this.studentTransaction,
      nextPage: nextPage ?? this.nextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class StudentTransactionLoading extends StudentTransactionState {
  const StudentTransactionLoading();
}

class StudentTransactionError extends StudentTransactionState {
  final String message;
  const StudentTransactionError({required this.message});
}
