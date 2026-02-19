import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepositoryInterface walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<FetchWalletDataEvent>(_onFetchWalletData);
    on<FundWalletEvent>(_onFundWallet);
  }

  bool _hasFetchedOnce = false;
  Future<void> _onFetchWalletData(
    FetchWalletDataEvent event,
    Emitter<WalletState> emit,
  ) async {
    final isForcedRefresh = event.forceRefresh;

    if (_hasFetchedOnce && !isForcedRefresh) return;

    try {
      final wallet = await walletRepository.getWallet();
      _hasFetchedOnce = true;
      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onFundWallet(
    FundWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(const WalletLoading());
      await Future.delayed(const Duration(seconds: 2));
      emit(const WalletInitial());
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
