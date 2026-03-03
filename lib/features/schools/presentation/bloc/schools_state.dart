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
  final int? nextPage;
  final bool isFetchingMore;

  const SchoolsLoaded({
    required this.schools,
    this.nextPage,
    this.isFetchingMore = false,
  });

  SchoolsLoaded copyWith({
    List<SchoolModel>? schools,
    int? nextPage,
    bool? isFetchingMore,
  }) {
    return SchoolsLoaded(
      schools: schools ?? this.schools,
      nextPage: nextPage ?? this.nextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class SchoolsError extends SchoolsState {
  final String message;
  const SchoolsError({required this.message});
}
