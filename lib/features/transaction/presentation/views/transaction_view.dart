import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    TransactionType type = TransactionType.TRANSFER;
    String name = walletTx.name;
    String iconKey = 'withdrawal';

    final desc = (walletTx.description ?? '').toLowerCase();
    final typeStr = walletTx.type.toUpperCase();

    if (typeStr == 'DEPOSIT' || typeStr == 'INFLOW') {
      type = TransactionType.DEPOSIT;
      name = 'Deposit';
      iconKey = 'deposit';
    } else if (typeStr == 'WITHDRAWAL') {
      type = TransactionType.WITHDRAWAL;
      name = 'Withdrawal';
      iconKey = 'withdrawal';
    } else if (typeStr == 'REVERSAL') {
      type = TransactionType.REVERSAL;
      name = 'Reversal';
      iconKey = 'withdrawal';
    } else {
      type = TransactionType.TRANSFER;
      if (desc.contains('airtime') || desc.contains('recharge')) {
        name = 'Airtime Recharge';
        iconKey = 'airtime';
      } else if (desc.contains('data') || desc.contains('internet')) {
        name = 'Data Bundle';
        iconKey = 'data';
      } else if (desc.contains('dstv') || desc.contains('gotv') || desc.contains('startimes') || desc.contains('cable')) {
        name = desc.contains('gotv') ? 'GOtv Subscription' : (desc.contains('dstv') ? 'DStv Subscription' : 'Cable TV Subscription');
        iconKey = 'cable';
      } else if (desc.contains('electricity') || desc.contains('meter') || desc.contains('power') || desc.contains('utility')) {
        name = 'Electricity';
        iconKey = 'electricity';
      }
    }

    TransactionStatus status = TransactionStatus.PENDING;
    final statusUpper = walletTx.status.toUpperCase();
    if (statusUpper == 'SUCCESS' || statusUpper == 'SUCCESSFUL') {
      status = TransactionStatus.SUCCESS;
    } else if (statusUpper == 'FAILED') {
      status = TransactionStatus.FAILED;
    } else if (statusUpper == 'REVERSED') {
      status = TransactionStatus.REVERSED;
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
      icon: iconKey,
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

class _TransactionIcon extends StatelessWidget {
  final String iconType;

  const _TransactionIcon({required this.iconType});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (iconType.toLowerCase()) {
      case 'airtime':
        iconData = Icons.phone_iphone_rounded;
        iconColor = Colors.purple.shade700;
        bgColor = Colors.purple.shade50;
        break;
      case 'data':
        iconData = Icons.wifi_rounded;
        iconColor = Colors.teal.shade700;
        bgColor = Colors.teal.shade50;
        break;
      case 'cable':
      case 'cabletv':
        iconData = Icons.tv_rounded;
        iconColor = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        break;
      case 'electricity':
        iconData = Icons.bolt_rounded;
        iconColor = Colors.amber.shade900;
        bgColor = Colors.amber.shade50;
        break;
      case 'deposit':
        iconData = Icons.arrow_downward_rounded;
        iconColor = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        break;
      case 'withdrawal':
      default:
        iconData = Icons.arrow_upward_rounded;
        iconColor = Colors.red.shade700;
        bgColor = Colors.red.shade50;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 22,
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
    final displayDate = DateFormat('dd MMM yyyy, hh:mm a')
        .format(transaction.transactionAt.toLocal());

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
            _TransactionIcon(iconType: transaction.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyMd(transaction.name, color: AppColors.textPrimary),
                  const SizedBox(height: 4),
                  CaptionMd(
                    displayDate,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BodyMd(transaction.amount, color: AppColors.textPrimary),
                const SizedBox(height: 4),
                CaptionMd(
                  transaction.status.name,
                  color: transaction.status == TransactionStatus.SUCCESS
                      ? AppColors.success
                      : (transaction.status == TransactionStatus.PENDING ||
                              transaction.status == TransactionStatus.REVERSED)
                          ? AppColors.warning
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
