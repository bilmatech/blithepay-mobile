import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/schools_repository.dart';
import 'schools_event.dart';
import 'schools_state.dart';

class SchoolsBloc extends Bloc<SchoolsEvent, SchoolsState> {
  final SchoolsRepository repository;

  SchoolsBloc({required this.repository}) : super(const SchoolsInitial()) {
    on<GetSchoolsEvent>(_onGetSchools);
    on<SearchSchoolsEvent>(_onSearchSchools);
  }

  Future<void> _onGetSchools(GetSchoolsEvent event, Emitter<SchoolsState> emit) async {
    emit(const SchoolsLoading());
    try {
      final schools = await repository.getSchools();
      emit(SchoolsLoaded(schools: schools));
    } catch (e) {
      emit(SchoolsError(message: e.toString()));
    }
  }

  Future<void> _onSearchSchools(SearchSchoolsEvent event, Emitter<SchoolsState> emit) async {
    emit(const SchoolsLoading());
    try {
      final schools = await repository.searchSchools(event.query);
      emit(SchoolsLoaded(schools: schools));
    } catch (e) {
      emit(SchoolsError(message: e.toString()));
    }
  }
}
