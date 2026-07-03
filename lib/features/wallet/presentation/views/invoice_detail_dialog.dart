import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class InvoiceDetailDialog extends StatelessWidget {
  final String feeType;
  final String invoiceNumber;
  final String publishedDate;
  final String dueDate;
  final double totalAmount;
  final Map<String, double> feeBreakdown;
  final VoidCallback onPayNow;

  const InvoiceDetailDialog({
    super.key,
    required this.feeType,
    required this.invoiceNumber,
    required this.publishedDate,
    required this.dueDate,
    required this.totalAmount,
    required this.feeBreakdown,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feeType, style: AppTextStyles.heading2),
                    Text(
                      'Invoice #$invoiceNumber',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Published on\n$publishedDate',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...feeBreakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.bodyMedium),
                    Text(
                      'N${entry.value.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due: $dueDate',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Total: N${totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecondaryOutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    label: 'Close',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPayNow();
                    },
                    label: 'Pay Now',
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
