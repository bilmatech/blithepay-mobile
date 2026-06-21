import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_table_loader.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WalletTransactionBloc>().add(
      GetTransactionsEvent(page: 1, limit: 20, refresh: true),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final state = context.read<WalletTransactionBloc>().state;

      if (state is WalletTransactionLoaded &&
          state.nextPage != null &&
          !state.isFetchingMore) {
        context.read<WalletTransactionBloc>().add(
          GetTransactionsEvent(page: state.nextPage!, limit: 20),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TransactionModel _mapToTransactionModel(WalletTransactionModel walletTx) {
    TransactionType type = TransactionType.other;
    String name = walletTx.name;
    String icon = '💸';

    final desc = (walletTx.description ?? '').toLowerCase();
    final typeStr = walletTx.type.toLowerCase();

    if (desc.contains('airtime') || typeStr.contains('airtime') || desc.contains('recharge')) {
      type = TransactionType.airtime;
      name = 'Airtime Recharge';
      icon = '📱';
    } else if (desc.contains('data') || desc.contains('internet') || typeStr.contains('data') || typeStr.contains('internet')) {
      type = TransactionType.data;
      name = 'Data Bundle';
      icon = '📶';
    } else if (desc.contains('dstv') || desc.contains('gotv') || desc.contains('startimes') || desc.contains('cable') || typeStr.contains('cable')) {
      type = TransactionType.cable;
      name = desc.contains('gotv') ? 'GOtv Subscription' : (desc.contains('dstv') ? 'DStv Subscription' : 'Cable TV Subscription');
      icon = '📺';
    } else if (desc.contains('electricity') || desc.contains('meter') || desc.contains('power') || typeStr.contains('electricity') || typeStr.contains('utility')) {
      type = TransactionType.electricity;
      name = 'Electricity';
      icon = '⚡';
    } else if (typeStr == 'deposit' || typeStr == 'inflow') {
      type = TransactionType.other;
      name = 'Deposit';
      icon = '💰';
    } else {
      type = TransactionType.other;
      name = 'Withdrawal';
      icon = '💸';
    }

    TransactionStatus status = TransactionStatus.pending;
    final statusLower = walletTx.status.toLowerCase();
    if (statusLower == 'success' || statusLower == 'successful') {
      status = TransactionStatus.successful;
    } else if (statusLower == 'failed') {
      status = TransactionStatus.failed;
    }

    TransactionFlow flow = walletTx.flow.toLowerCase() == 'inflow'
        ? TransactionFlow.inflow
        : TransactionFlow.outflow;

    final double amountVal = double.tryParse(walletTx.amount) ?? 0.0;
    final double netAmountVal = double.tryParse(walletTx.netAmount) ?? 0.0;
    final double feesVal = double.tryParse(walletTx.fees) ?? 0.0;

    final formattedAmount = Helpers.formattedAmount(amountVal.toString()).replaceAll('₦', 'N');
    final formattedNetAmount = Helpers.formattedAmount(netAmountVal.toString()).replaceAll('₦', 'N');

    return TransactionModel(
      name: name,
      desc: walletTx.description ?? '',
      transactionAt: DateTime.tryParse(walletTx.transactionAt) ?? DateTime.now(),
      amount: formattedAmount,
      netAmount: formattedNetAmount,
      reference: walletTx.reference,
      status: status,
      flow: flow,
      type: type,
      icon: icon,
      fees: feesVal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'Transactions', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter and Sort Controls
            Row(
              children: [
                const Spacer(),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, size: 20),
                    label: const Text('Filter'),
                    iconAlignment: IconAlignment.end,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    label: const Text('Sort by'),
                    iconAlignment: IconAlignment.end,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      iconAlignment: IconAlignment.end,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 20),
            // Transactions List
            Expanded(
              child: BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
                builder: (context, state) {
                  if (state is WalletTransactionLoading) {
                    return const ShimmerTableLoader();
                  }

                  if (state is WalletTransactionError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  if (state is WalletTransactionLoaded) {
                    final list = state.transactions;
                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'No transactions found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<WalletTransactionBloc>().add(
                          GetTransactionsEvent(page: 1, limit: 20, refresh: true),
                        );
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: list.length + (state.isFetchingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < list.length) {
                            final rawTx = list[index];
                            final txModel = _mapToTransactionModel(rawTx);
                            return _TransactionCard(
                              transaction: txModel,
                              rawTransaction: rawTx,
                            );
                          }

                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final WalletTransactionModel rawTransaction;

  const _TransactionCard({
    required this.transaction,
    required this.rawTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.transactionDetail, extra: rawTransaction);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  transaction.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyMd(transaction.name, color: AppColors.textPrimary),
                  CaptionMd(
                    transaction.transactionAt.toLocal().toString(),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BodyMd(transaction.amount, color: AppColors.textPrimary),
                CaptionMd(
                  transaction.status.name,
                  color: transaction.status == TransactionStatus.successful
                      ? AppColors.success
                      : AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
