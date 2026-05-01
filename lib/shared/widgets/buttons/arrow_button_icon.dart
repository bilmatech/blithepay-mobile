import 'package:blithepay/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BackArrowButtonIcon extends StatelessWidget {
  const BackArrowButtonIcon({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: onPressed ?? () => Navigator.pop(context),
        ),
      ),
    );
  }
}
