abstract class StudentsEvent {
  const StudentsEvent();
}

class GetLinkedStudentsEvent extends StudentsEvent {
  const GetLinkedStudentsEvent();
}

class GetStudentDetailsEvent extends StudentsEvent {
  final String studentId;
  const GetStudentDetailsEvent(this.studentId);
}
