import 'package:blithepay/features/dashboard/presentation/models/dashboard_model.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepositoryInterface walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<FetchWalletDataEvent>(_onFetchWalletData);
    on<GetTransactionsEvent>(_onGetTransactions);
    on<FundWalletEvent>(_onFundWallet);
  }

  Future<void> _onFetchWalletData(
    FetchWalletDataEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(const WalletLoading());

      final wallet = await walletRepository.getWallet();

      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(const WalletLoading());
      await Future.delayed(const Duration(seconds: 1));
      final transactions = [
        const TransactionItem(
          title: 'Tuition fee',
          amount: 'N300,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        const TransactionItem(
          title: 'Wallet Deposit',
          amount: 'N200,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        const TransactionItem(
          title: 'Wallet Withdrawal',
          amount: 'N100,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        const TransactionItem(
          title: 'Textbooks',
          amount: 'N300,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        const TransactionItem(
          title: 'Tuition fee',
          amount: 'N300,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
      ];
      emit(TransactionsLoaded(transactions: transactions));
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
