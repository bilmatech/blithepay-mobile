import '../../data/models/school_model.dart';

abstract class SchoolsState {
  const SchoolsState();
}

class SchoolsInitial extends SchoolsState {
  const SchoolsInitial();
}

class SchoolsLoading extends SchoolsState {
  const SchoolsLoading();
}

class SchoolsLoaded extends SchoolsState {
  final List<SchoolModel> schools;
  const SchoolsLoaded({required this.schools});
}

class SchoolsError extends SchoolsState {
  final String message;
  const SchoolsError({required this.message});
}
