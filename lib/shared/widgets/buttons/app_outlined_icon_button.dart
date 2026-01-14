import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppOutlinedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final TextStyle? textStyle;

  const AppOutlinedIconButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.iconSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 6,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding,
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: borderColor ?? AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle ?? AppTextStyles.bodySmall),
          const SizedBox(width: 6),
          Icon(icon, size: iconSize),
        ],
      ),
    );
  }
}
