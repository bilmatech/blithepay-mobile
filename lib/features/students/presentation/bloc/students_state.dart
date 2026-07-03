import 'package:blithepay/features/schools/data/models/linked_student_model.dart';
import 'package:blithepay/features/students/data/models/student_transaction_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';

abstract class StudentsState {
  const StudentsState();
}

class StudentsInitial extends StudentsState {
  const StudentsInitial();
}

class StudentsLoading extends StudentsState {
  const StudentsLoading();
}

class StudentsLoaded extends StudentsState {
  final List<VerifiedStudentModel> students;
  final int nextPage;
  final Set<String> loadingStudentIds; // <-- track loading per student
  final String? errorMessage;

  const StudentsLoaded({
    required this.students,
    required this.nextPage,
    this.loadingStudentIds = const {},
    this.errorMessage,
  });

  StudentsLoaded copyWith({
    List<VerifiedStudentModel>? students,
    int? nextPage,
    Set<String>? loadingStudentIds,
    String? errorMessage,
  }) {
    return StudentsLoaded(
      students: students ?? this.students,
      nextPage: nextPage ?? this.nextPage,
      loadingStudentIds: loadingStudentIds ?? this.loadingStudentIds,
      errorMessage: errorMessage,
    );
  }
}

class StudentDetailsLoaded extends StudentsState {
  final VerifiedStudentModel student;
  const StudentDetailsLoaded({required this.student});
}

class StudentsError extends StudentsState {
  final String message;
  const StudentsError({required this.message});
}

class VerifyStudentS extends StudentsState {} // <-- new

class VerifyStudentSuccess extends StudentsState {
  final VerifiedStudentModel? model;
  const VerifyStudentSuccess({this.model});
} // <-- new

class StudentsLinking extends StudentsState {
  final String studentId;
  const StudentsLinking({required this.studentId});
}

class StudentsLinkSuccess extends StudentsState {
  final LinkedStudentModel? model;
  const StudentsLinkSuccess({this.model});
}

class FeeTransactionLoaded extends StudentsState {
  final List<StudentTransactionModel> wallet;
  final int? nextPage;
  final bool isFetchingMore;

  const FeeTransactionLoaded({
    required this.wallet,
    this.nextPage,
    this.isFetchingMore = false,
  });

  FeeTransactionLoaded copyWith({
    List<StudentTransactionModel>? wallet,
    int? nextPage,
    bool? isFetchingMore,
  }) {
    return FeeTransactionLoaded(
      wallet: wallet ?? this.wallet,
      nextPage: nextPage ?? this.nextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}
