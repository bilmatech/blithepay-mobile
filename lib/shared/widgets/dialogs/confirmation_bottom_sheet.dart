import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../buttons/primary_button.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmButtonLabel;
  final String cancelButtonLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool isDangerous;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.confirmButtonLabel,
    required this.cancelButtonLabel,
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SecondaryOutlinedButton(
                  height: 40,
                  label: cancelButtonLabel,
                  onPressed: () {
                    Navigator.pop(context);
                    onCancel?.call();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  height: 40,
                  label: confirmButtonLabel,
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String confirmButtonLabel,
    required String cancelButtonLabel,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDangerous = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ConfirmationBottomSheet(
        title: title,
        subtitle: subtitle,
        confirmButtonLabel: confirmButtonLabel,
        cancelButtonLabel: cancelButtonLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDangerous: isDangerous,
      ),
    );
  }
}
