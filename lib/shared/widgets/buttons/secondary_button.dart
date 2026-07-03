import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double? width;
  final IconData? prefixIcon;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.prefixIcon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextButton.icon(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.disabled,
        ),
        icon: prefixIcon != null
            ? Icon(prefixIcon, color: textColor ?? AppColors.primary)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: AppTextStyles.link.copyWith(
            color: isEnabled
                ? (textColor ?? AppColors.primary)
                : AppColors.disabled,
          ),
        ),
      ),
    );
  }
}
