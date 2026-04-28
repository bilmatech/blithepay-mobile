import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';

class SecondaryOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final TextStyle? textStyle;
  final Widget? leading;

  const SecondaryOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.iconSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 6,
    this.borderColor,
    this.textStyle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        minimumSize: const Size(0, 56),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: borderColor ?? AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: leading != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                leading!,
                const SizedBox(width: 8),
                Text(
                  label,
                  style:
                      textStyle ??
                      const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            )
          : Text(
              label,
              style: textStyle ?? const TextStyle(color: AppColors.textPrimary),
            ),
    );
  }
}
