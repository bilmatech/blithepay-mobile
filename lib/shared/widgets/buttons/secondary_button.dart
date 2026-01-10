import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double? width;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.disabled,
        ),
        child: Text(
          text,
          style: AppTextStyles.link.copyWith(
            color: isEnabled ? AppColors.primary : AppColors.disabled,
          ),
        ),
      ),
    );
  }
}
