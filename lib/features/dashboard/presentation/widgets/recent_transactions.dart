import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class RecentTransactions extends StatelessWidget {
  final List<WalletTransactionModel> transactions;

  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      // Show friendly empty state
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your recent transactions will appear here once available.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final dashboardTransactions = transactions.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.transactions);
              },
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dashboardTransactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = dashboardTransactions[index];
            return TransactionContainer(transaction: transaction);
          },
        ),
      ],
    );
  }
}

class TransactionContainer extends StatelessWidget {
  const TransactionContainer({super.key, required this.transaction});

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    String iconKey = 'withdrawal';
    String name = transaction.name;
    final desc = (transaction.description ?? '').toLowerCase();
    final typeStr = transaction.type.toLowerCase();

    if (desc.contains('airtime') || typeStr.contains('airtime') || desc.contains('recharge')) {
      name = 'Airtime Recharge';
      iconKey = 'airtime';
    } else if (desc.contains('data') || desc.contains('internet') || typeStr.contains('data') || typeStr.contains('internet')) {
      name = 'Data Bundle';
      iconKey = 'data';
    } else if (desc.contains('dstv') || desc.contains('gotv') || desc.contains('startimes') || desc.contains('cable') || typeStr.contains('cable')) {
      name = desc.contains('gotv') ? 'GOtv Subscription' : (desc.contains('dstv') ? 'DStv Subscription' : 'Cable TV Subscription');
      iconKey = 'cable';
    } else if (desc.contains('electricity') || desc.contains('meter') || desc.contains('power') || typeStr.contains('electricity') || typeStr.contains('utility')) {
      name = 'Electricity';
      iconKey = 'electricity';
    } else if (typeStr == 'deposit' || typeStr == 'inflow') {
      name = 'Deposit';
      iconKey = 'deposit';
    } else {
      name = 'Withdrawal';
      iconKey = 'withdrawal';
    }

    final parsedDate = DateTime.tryParse(transaction.transactionAt) ?? DateTime.now();
    final displayDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate.toLocal());
    final isSuccess = transaction.status.toLowerCase() == 'success' || transaction.status.toLowerCase() == 'successful';

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.transactionDetail, extra: transaction);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightBack.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _TransactionIcon(iconType: iconKey),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Helpers.formattedAmount(
                    transaction.amount,
                    flow: transaction.flow,
                  ).replaceAll('₦', 'N'),
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.status.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSuccess ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
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
