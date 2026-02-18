import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepositoryInterface walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<FetchWalletDataEvent>(_onFetchWalletData);
    // on<GetTransactionsEvent>(_onGetTransactions);
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

  // Future<void> _onFetchWalletData(
  //   FetchWalletDataEvent event,
  //   Emitter<WalletState> emit,
  // ) async {
  //   try {
  //     emit(const WalletLoading());

  //     final wallet = await walletRepository.getWallet();

  //     emit(WalletLoaded(wallet));
  //   } catch (e) {
  //     emit(WalletError(e.toString()));
  //   }
  // }

  // bool _hasWalletTFetchedOnce = false; // at bloc level

  // Future<void> _onGetTransactions(
  //   GetTransactionsEvent event,
  //   Emitter<WalletState> emit,
  // ) async {
  //   final currentState = state;

  //   List<WalletTransactionModel> oldTransactions = [];

  //   if (!event.refresh &&
  //       currentState is WalletTransactionLoaded &&
  //       event.page > 1) {
  //     oldTransactions = currentState.wallet;
  //   }

  //   final showShimmer = !_hasWalletTFetchedOnce && !event.refresh;

  //   if (showShimmer) {
  //     emit(const WalletTransactionLoading());
  //     await Future.delayed(const Duration(milliseconds: 250));
  //   }
  //   if (_hasWalletTFetchedOnce && !event.refresh) return;

  //   try {
  //     final result = await walletRepository.getWalletTransaction(
  //       page: event.page,
  //       limit: event.limit,
  //     );

  //     final updatedTransactions = event.refresh
  //         ? result.transactions
  //         : [...oldTransactions, ...result.transactions];

  //     _hasWalletTFetchedOnce = true;

  //     emit(
  //       WalletTransactionLoaded(
  //         wallet: updatedTransactions,
  //         nextPage: result.nextPage,
  //         isFetchingMore: false,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(WalletError(extractError(e)));

  //     // Re-emit old state to avoid clearing screen
  //     if (currentState is WalletTransactionLoaded) {
  //       emit(currentState);
  //     }
  //   }
  // }

  // Future<void> _onGetTransactions(
  //   GetTransactionsEvent event,
  //   Emitter<WalletState> emit,
  // ) async {
  //   final currentState = state;

  //   // FIRST LOAD
  //   if (currentState is! WalletTransactionLoaded) {
  //     emit(const WalletLoading());

  //     try {
  //       final result = await walletRepository.getWalletTransaction(
  //         page: event.page,
  //         limit: event.limit,
  //       );

  //       emit(
  //         WalletTransactionLoaded(
  //           wallet: result.transactions,
  //           nextPage: result.nextPage,
  //         ),
  //       );
  //     } catch (e) {
  //       emit(WalletError(extractError(e)));
  //     }

  //     return;
  //   }

  //   // PAGINATION LOAD
  //   if (currentState.nextPage == null) return; // No more pages
  //   if (currentState.isFetchingMore) return; // Already fetching

  //   emit(currentState.copyWith(isFetchingMore: true));

  //   try {
  //     final result = await walletRepository.getWalletTransaction(
  //       page: currentState.nextPage!,
  //       limit: event.limit,
  //     );

  //     final updatedWallet = [...currentState.wallet, ...result.transactions];

  //     emit(
  //       WalletTransactionLoaded(
  //         wallet: updatedWallet,
  //         nextPage: result.nextPage,
  //         isFetchingMore: false,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(currentState.copyWith(isFetchingMore: false));
  //   }
  // }

  // Future<void> _onGetTransactions(
  //   GetTransactionsEvent event,
  //   Emitter<WalletState> emit,
  // ) async {
  //   try {
  //     emit(const WalletLoading());
  //     await Future.delayed(const Duration(seconds: 1));
  //     final transactions = [
  //       const TransactionItem(
  //         title: 'Tuition fee',
  //         amount: 'N300,000.00',
  //         date: '11-09-25',
  //         time: '11:15',
  //         status: 'Successful',
  //       ),
  //       const TransactionItem(
  //         title: 'Wallet Deposit',
  //         amount: 'N200,000.00',
  //         date: '11-09-25',
  //         time: '11:15',
  //         status: 'Successful',
  //       ),
  //       const TransactionItem(
  //         title: 'Wallet Withdrawal',
  //         amount: 'N100,000.00',
  //         date: '11-09-25',
  //         time: '11:15',
  //         status: 'Successful',
  //       ),
  //       const TransactionItem(
  //         title: 'Textbooks',
  //         amount: 'N300,000.00',
  //         date: '11-09-25',
  //         time: '11:15',
  //         status: 'Successful',
  //       ),
  //       const TransactionItem(
  //         title: 'Tuition fee',
  //         amount: 'N300,000.00',
  //         date: '11-09-25',
  //         time: '11:15',
  //         status: 'Successful',
  //       ),
  //     ];
  //     emit(TransactionsLoaded(transactions: transactions));
  //   } catch (e) {
  //     emit(WalletError(e.toString()));
  //   }
  // }

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
