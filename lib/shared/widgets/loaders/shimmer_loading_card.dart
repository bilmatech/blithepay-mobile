import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

class ShimmerLoadingCard extends StatelessWidget {
  final double height;
  final double? width;

  const ShimmerLoadingCard({
    super.key,
    this.height = 120,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.disabled,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
