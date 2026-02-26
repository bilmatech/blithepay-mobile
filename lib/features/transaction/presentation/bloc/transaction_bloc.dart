import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTransactionBloc
    extends Bloc<WalletTransactionEvent, WalletTransactionState> {
  final WalletRepositoryInterface walletRepository;

  WalletTransactionBloc({required this.walletRepository})
    : super(WalletTransactionInitial()) {
    on<GetTransactionsEvent>(_onGetTransactions);
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<WalletTransactionState> emit,
  ) async {
    final currentState = state;

    // Block duplicate pagination calls
    if (currentState is WalletTransactionLoaded &&
        currentState.isFetchingMore &&
        !event.refresh) {
      return;
    }

    List<WalletTransactionModel> oldTransactions = [];

    if (!event.refresh &&
        currentState is WalletTransactionLoaded &&
        event.page > 1) {
      oldTransactions = currentState.transactions;

      emit(currentState.copyWith(isFetchingMore: true));
    } else if (event.page == 1 && !event.refresh) {
      emit(WalletTransactionLoading());
    }

    try {
      final result = await walletRepository.getWalletTransaction(
        page: event.page,
        limit: event.limit,
      );

      emit(
        WalletTransactionLoaded(
          transactions: event.refresh
              ? result.transactions
              : [...oldTransactions, ...result.transactions],
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      if (currentState is WalletTransactionLoaded) {
        emit(currentState.copyWith(isFetchingMore: false));
      } else {
        emit(WalletTransactionError(e.toString()));
      }
    }
  }
}
