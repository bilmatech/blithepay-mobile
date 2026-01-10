abstract class SchoolsEvent {
  const SchoolsEvent();
}

class GetSchoolsEvent extends SchoolsEvent {
  const GetSchoolsEvent();
}

class SearchSchoolsEvent extends SchoolsEvent {
  final String query;
  const SearchSchoolsEvent(this.query);
}
