import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../models/dashboard_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AppLocalDataSource _localDataSource;
  final WalletRepositoryInterface walletRepository;

  DashboardBloc({
    required AppLocalDataSource localDataSource,
    required this.walletRepository,
  }) : _localDataSource = localDataSource,
       super(const DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<SelectChild>(_onSelectChild);
  }

  bool _hasFetchedOnce = false;

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final bool isFirstLoad = !_hasFetchedOnce;
    final bool isForcedRefresh = event.forceRefresh;

    // First load → show loader
    if (isFirstLoad) {
      emit(const DashboardLoading());
    }
    try {
      // 1. Fetch user session
      final userSession = await _localDataSource.getSession();
      final firstName =
          '${userSession?.user?.firstName ?? ''} ${userSession?.user?.lastName ?? ''}';

      // 2. Greeting logic
      final hour = DateTime.now().hour;
      final greeting = hour < 12
          ? 'Good Morning'
          : hour < 17
          ? 'Good Afternoon'
          : hour < 21
          ? 'Good Evening'
          : 'Good Night';

      // 3. Fetch wallet from API
      final wallet = await walletRepository.getWallet();

      // 4. Build dashboard model
      final dashboardData = DashboardModel(
        greeting: greeting,
        userName: firstName.trim(),
        avatarUrl: userSession?.user?.profileImage ?? '',
        totalOutstanding: '', // hook up later if needed
        nextDueDate: '',
        walletBalance: wallet.ngnBalance,
        selectedChildId: '',
        selectedChildName: '',
        transactions: DashboardModel.mock().transactions,
      );
      _hasFetchedOnce = true;

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      if (!isFirstLoad && state is DashboardLoaded) {
        return;
      }
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
