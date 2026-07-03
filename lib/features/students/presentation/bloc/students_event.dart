abstract class StudentsEvent {
  const StudentsEvent();
}

class GetLinkedStudentsEvent extends StudentsEvent {
  final int page;
  final int limit;
  final String? studentCode;
  final bool refresh; // new flag

  const GetLinkedStudentsEvent({
    this.page = 1,
    this.limit = 20,
    this.studentCode,
    this.refresh = false,
  });

  List<Object?> get props => [page, limit, studentCode, refresh];
}

class GetLivePortalStudentsEvent extends StudentsEvent {
  final int page;
  final int limit;

  const GetLivePortalStudentsEvent({this.page = 1, this.limit = 20});

  List<Object?> get props => [page, limit];
}

class VerifyChildEvent extends StudentsEvent {
  final String schoolId;
  final String regNum;
  final String studentCode;

  const VerifyChildEvent({
    this.schoolId = '',
    this.regNum = '',
    this.studentCode = '',
  });
}

class LinkChildEvent extends StudentsEvent {
  final String studentId;
  final String studentCode;
  const LinkChildEvent({this.studentCode = '', this.studentId = ''});
}

class UNLinkChildEvent extends StudentsEvent {
  final String studentId;
  final String studentCode;
  const UNLinkChildEvent({this.studentCode = '', this.studentId = ''});
}

class GetStudentDetailsEvent extends StudentsEvent {
  final String studentId;
  const GetStudentDetailsEvent(this.studentId);
}

