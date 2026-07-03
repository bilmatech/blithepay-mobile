import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class WalletUpdateDialog extends StatelessWidget {
  final double amount;
  final VoidCallback onViewReceipt;

  const WalletUpdateDialog({
    super.key,
    required this.amount,
    required this.onViewReceipt,
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
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: .1),
              ),
              child: const Center(
                child: Icon(Icons.check, color: AppColors.success, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            // const Text(
            //   'Wallet balance updated!',
            //   style: AppTextStyles.heading2,
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 8),
            Text(
              'Wallet balance updated! N${amount.toStringAsFixed(2)} has been added to your balance.',
              style: AppTextStyles.bodyMedium.copyWith(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'View Receipt',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
