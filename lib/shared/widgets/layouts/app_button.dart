import 'app_text.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isEnabled;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.padding,
    this.isLoading = false,
    this.isEnabled = true,
    this.borderRadius = AppSpacing.radiusBase,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AppSpacing.buttonHeightMd,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.borderGrey,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : HeadingMd(label, color: foregroundColor ?? AppColors.white),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? foregroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isEnabled;
  final double borderRadius;
  final double borderWidth;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor,
    this.foregroundColor,
    this.height,
    this.padding,
    this.isLoading = false,
    this.isEnabled = true,
    this.borderRadius = AppSpacing.radiusBase,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AppSpacing.buttonHeightMd,
      child: OutlinedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primary,
          side: BorderSide(color: borderColor ?? AppColors.primary, width: borderWidth),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          disabledForegroundColor: AppColors.textHint,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : HeadingMd(label, color: foregroundColor ?? AppColors.primary),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isEnabled;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading || !isEnabled ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : HeadingXSm(label, color: foregroundColor ?? AppColors.primary),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = AppSpacing.buttonHeightMd,
    this.iconSize = AppSpacing.iconMd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: foregroundColor ?? AppColors.primary,
        iconSize: iconSize,
      ),
    );
  }
}
