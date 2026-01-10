import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/wallet_model.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletInitial()) {
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
      await Future.delayed(const Duration(seconds: 2));
      final wallet = WalletModel(
        balance: 'N200,000.32',
        accountNumber: '0123456789',
        lastUpdated: 'Tuesday, 11 July, 2026',
        transactions: [
          TransactionModel(
            id: '1',
            amount: 'N300,000.00',
            type: 'Withdrawal',
            method: 'Wallet',
            date: '11-09-25. 11:15',
            status: 'Completed',
          ),
        ],
      );
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
        {
          'date': '11-09-25. 11:15',
          'amount': 'N300,000.00',
          'method': 'Wallet',
          'type': 'Withdrawal',
        },
        {
          'date': '11-09-25. 11:15',
          'amount': 'N300,000.00',
          'method': 'Wallet',
          'type': 'Fee Payment',
        },
        {
          'date': '11-09-25. 11:15',
          'amount': 'N300,000.00',
          'method': 'Wallet',
          'type': 'Deposit',
        },
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
