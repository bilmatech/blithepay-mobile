import 'package:blithepay/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SecondaryOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final TextStyle? textStyle;

  const SecondaryOutlinedButton({
    super.key,
    required this.label,
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
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
