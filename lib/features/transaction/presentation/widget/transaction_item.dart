import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/transaction/domain/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(_getIcon(), style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM d, yyyy hh:mm a',
                    ).format(transaction.dateTime),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${transaction.amount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusLabel(),
                  style: AppTextStyles.caption.copyWith(
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getIcon() {
    switch (transaction.serviceType) {
      case 'airtime':
        return '📱';
      case 'data':
        return '📡';
      case 'electricity':
        return '⚡';
      case 'cableTv':
        return '📺';
      case 'betting':
        return '🎲';
      case 'feePayment':
        return '🎓';
      case 'school':
        return '🏫';
      default:
        return '💳';
    }
  }

  String _getStatusLabel() {
    return transaction.status.toString().split('.').last[0].toUpperCase() +
        transaction.status.toString().split('.').last.substring(1);
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.successful:
        return AppColors.success;
      case TransactionStatus.failed:
        return AppColors.error;
      case TransactionStatus.pending:
        return AppColors.warning;
    }
  }
}
