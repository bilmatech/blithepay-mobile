import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../models/dashboard_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AppLocalDataSource _localDataSource;
  DashboardBloc(this._localDataSource) : super(const DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<SelectChild>(_onSelectChild);
  }
  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // Fetch saved user session
      final userSession = await _localDataSource.getSession();
      final firstName = '${userSession?.user?.firstName} ${userSession?.user?.lastName}';

      // Determine greeting based on time
      final hour = DateTime.now().hour;
      String greeting;
      if (hour >= 5 && hour < 12) {
        greeting = 'Good Morning';
      } else if (hour >= 12 && hour < 17) {
        greeting = 'Good Afternoon';
      } else if (hour >= 17 && hour < 21) {
        greeting = 'Good Evening';
      } else {
        greeting = 'Good Night';
      }

      final dashboardData = DashboardModel(
        greeting: greeting,
        userName: firstName,
        avatarUrl: userSession?.user?.profileImage ?? '',
        totalOutstanding: '',
        nextDueDate: '',
        walletBalance: '',
        selectedChildId: '',
        selectedChildName: '',
        transactions: DashboardModel.mock().transactions,
      );

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
  // Future<void> _onFetchDashboardData(
  //   FetchDashboardData event,
  //   Emitter<DashboardState> emit,
  // ) async {
  //   if (state is DashboardLoaded) return;
  //   emit(const DashboardLoading());
  //   try {
  //     // Simulate API call
  //     await Future.delayed(const Duration(seconds: 2));

  //     final mockData = DashboardModel.mock();
  //     emit(DashboardLoaded(mockData));
  //   } catch (e) {
  //     emit(DashboardError(e.toString()));
  //   }
  // }

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
