abstract class SchoolsEvent {
  const SchoolsEvent();
}

class GetSchoolPortalEvent extends SchoolsEvent {
  final int page;
  final int limit;

  const GetSchoolPortalEvent({this.page = 1, this.limit = 20});

  List<Object?> get props => [page, limit];
}

class GetSchoolsEvent extends SchoolsEvent {
  const GetSchoolsEvent();
}

class SearchSchoolsEvent extends SchoolsEvent {
  final String query;
  const SearchSchoolsEvent(this.query);
}
