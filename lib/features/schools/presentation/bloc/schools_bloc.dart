import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/schools/data/models/school_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/schools_repository.dart';
import 'schools_event.dart';
import 'schools_state.dart';

class SchoolsBloc extends Bloc<SchoolsEvent, SchoolsState> {
  final SchoolsRepository repository;

  SchoolsBloc({required this.repository}) : super(const SchoolsInitial()) {
    on<GetSchoolPortalEvent>(_onGetSchoolPortal);
    on<GetSchoolsEvent>(_onGetSchools);
    on<SearchSchoolsEvent>(_onSearchSchools);
  }

  Future<void> _onGetSchoolPortal(
    GetSchoolPortalEvent event,
    Emitter<SchoolsState> emit,
  ) async {
    final currentState = state;

    // FIRST LOAD
    if (currentState is! SchoolsLoaded) {
      emit(const SchoolsLoading());

      try {
        final result = await repository.getSchoolPortal(
          page: event.page,
          limit: event.limit,
        );

        emit(SchoolsLoaded(schools: result.school, nextPage: result.nextPage));
      } catch (e) {
        emit(SchoolsError(message: extractError(e)));
      }

      return;
    }

    // PAGINATION LOAD
    if (currentState.nextPage == null) return; // No more pages
    if (currentState.isFetchingMore) return; // Already fetching

    emit(currentState.copyWith(isFetchingMore: true));

    try {
      final result = await repository.getSchoolPortal(
        page: currentState.nextPage!,
        limit: event.limit,
      );

      final updatedSchools = [...currentState.schools, ...result.school];

      emit(
        SchoolsLoaded(
          schools: updatedSchools,
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }

  Future<void> _onGetSchools(
    GetSchoolsEvent event,
    Emitter<SchoolsState> emit,
  ) async {
    emit(const SchoolsLoading());
    try {
      final schools = await repository.getSchools();
      emit(SchoolsLoaded(schools: schools));
    } catch (e) {
      emit(SchoolsError(message: extractError(e)));
    }
  }

  Future<void> _onSearchSchools(
    SearchSchoolsEvent event,
    Emitter<SchoolsState> emit,
  ) async {
    emit(const SchoolsLoading());
    try {
      final schools = await repository.searchSchools(event.query);
      emit(SchoolsLoaded(schools: schools));
    } catch (e) {
      emit(SchoolsError(message: extractError(e)));
    }
  }
}
