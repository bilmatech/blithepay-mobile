import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import 'shimmer_widget.dart';

class ShimmerDashboardLoader extends StatelessWidget {
  const ShimmerDashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                const ShimmerWidget(
                  width: 50,
                  height: 50,
                  shapeType: ShapeType.circular,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      width: 100,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    ShimmerWidget(
                      width: 80,
                      height: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Cards shimmer
            _buildCardShimmer(),
            const SizedBox(height: 16),
            _buildCardShimmer(),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonShimmer(),
                _buildButtonShimmer(),
                _buildButtonShimmer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.disabled,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 12,
              color: AppColors.disabled,
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 16,
              color: AppColors.disabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.disabled,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
