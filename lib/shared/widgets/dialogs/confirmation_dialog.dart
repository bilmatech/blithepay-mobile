import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: AppTextStyles.heading2.copyWith(
          color: isDangerous ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDangerous ? AppColors.error : AppColors.primary,
            ),
          ),
          child: Text(
            cancelLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDangerous ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDangerous ? AppColors.error : AppColors.primary,
          ),
          child: Text(
            confirmLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
