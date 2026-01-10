import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/students_repository.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentsRepository repository;

  StudentsBloc({required this.repository}) : super(const StudentsInitial()) {
    on<GetLinkedStudentsEvent>(_onGetLinkedStudents);
    on<GetStudentDetailsEvent>(_onGetStudentDetails);
  }

  Future<void> _onGetLinkedStudents(
    GetLinkedStudentsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());
    try {
      final students = await repository.getLinkedStudents();
      emit(StudentsLoaded(students: students));
    } catch (e) {
      emit(StudentsError(message: e.toString()));
    }
  }

  Future<void> _onGetStudentDetails(
    GetStudentDetailsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());
    try {
      final student = await repository.getStudentDetails(event.studentId);
      emit(StudentDetailsLoaded(student: student));
    } catch (e) {
      emit(StudentsError(message: e.toString()));
    }
  }
}
