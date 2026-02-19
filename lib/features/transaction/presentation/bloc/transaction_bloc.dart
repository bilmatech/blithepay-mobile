import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTransactionBloc
    extends Bloc<WalletTransactionEvent, WalletTransactionState> {
  final WalletRepositoryInterface walletRepository;

  bool _hasFetchedOnce = false;

  WalletTransactionBloc({required this.walletRepository})
    : super(WalletTransactionInitial()) {
    on<GetTransactionsEvent>(_onGetTransactions);
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<WalletTransactionState> emit,
  ) async {
    final currentState = state;

    List<WalletTransactionModel> oldTransactions = [];

    if (!event.refresh &&
        currentState is WalletTransactionLoaded &&
        event.page > 1) {
      oldTransactions = currentState.transactions;
    }

    // Show shimmer only for first load
    final showShimmer = !_hasFetchedOnce && !event.refresh;

    if (showShimmer) emit(WalletTransactionLoading());
    if (_hasFetchedOnce && !event.refresh) return;

    try {
      final result = await walletRepository.getWalletTransaction(
        page: event.page,
        limit: event.limit,
      );

      final updatedTransactions = event.refresh
          ? result.transactions
          : [...oldTransactions, ...result.transactions];

      _hasFetchedOnce = true;

      emit(
        WalletTransactionLoaded(
          transactions: updatedTransactions,
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(WalletTransactionError(e.toString()));

      if (currentState is WalletTransactionLoaded) {
        emit(currentState); // prevent clearing UI
      }
    }
  }
}
