import '../../data/models/student_model.dart';

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
  final List<StudentModel> students;
  const StudentsLoaded({required this.students});
}

class StudentDetailsLoaded extends StudentsState {
  final StudentModel student;
  const StudentDetailsLoaded({required this.student});
}

class StudentsError extends StudentsState {
  final String message;
  const StudentsError({required this.message});
}
