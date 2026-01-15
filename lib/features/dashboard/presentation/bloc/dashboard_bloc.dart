import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../models/dashboard_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<SelectChild>(_onSelectChild);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) return;
    emit(const DashboardLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final mockData = DashboardModel.mock();
      emit(DashboardLoaded(mockData));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onSelectChild(
    SelectChild event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      final updated = currentState.dashboard.copyWith(
        selectedChildId: event.childId,
      );
      emit(DashboardLoaded(updated));
    }
  }
}
