import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum TransactionResultType { success, failure, insufficientBalance }

class TransactionResultDialog extends StatelessWidget {
  final TransactionResultType type;
  final String title;
  final String message;
  final String? amount;
  final String primaryButtonLabel;
  final String? secondaryButtonLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const TransactionResultDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.amount,
    required this.primaryButtonLabel,
    this.secondaryButtonLabel,
    required this.onPrimaryTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == TransactionResultType.success;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? AppColors.success.withValues(alpha: .1)
                    : AppColors.error.withValues(alpha: .1),
              ),
              child: Center(
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: isSuccess ? AppColors.success : AppColors.error,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (amount != null)
              Text(
                amount!,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimaryTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  primaryButtonLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            if (secondaryButtonLabel != null && onSecondaryTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSecondaryTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    secondaryButtonLabel!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
