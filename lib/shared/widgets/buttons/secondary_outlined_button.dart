import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';

class SecondaryOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double height; // ADD THIS
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final TextStyle? textStyle;
  final Widget? leading;

  const SecondaryOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 40, // DEFAULT 40
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = 6,
    this.borderColor,
    this.textStyle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // CONTROL HEIGHT HERE
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: padding,
          minimumSize: Size.zero, // IMPORTANT FIX
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
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style:
                          textStyle ??
                          const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              )
            : Text(
                label,
                overflow: TextOverflow.ellipsis,
                style:
                    textStyle ?? const TextStyle(color: AppColors.textPrimary),
              ),
      ),
    );
  }
}
