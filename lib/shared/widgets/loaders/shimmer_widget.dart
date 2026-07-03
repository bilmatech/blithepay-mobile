import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final ShapeType shapeType;

  const ShimmerWidget({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.shapeType = ShapeType.rectangular,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: _buildShape(),
    );
  }

  Widget _buildShape() {
    switch (shapeType) {
      case ShapeType.rectangular:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.disabled,
            borderRadius: borderRadius ?? BorderRadius.circular(4),
          ),
        );
      case ShapeType.circular:
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            color: AppColors.disabled,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  static Widget buildShimmerList({
    required int itemCount,
    double itemHeight = 60,
    double spacing = 8,
    BorderRadius? borderRadius,
  }) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => ShimmerWidget(
        height: itemHeight,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        shapeType: ShapeType.rectangular,
      ),
    );
  }

  static Widget buildShimmerGrid({
    required int itemCount,
    required int crossAxisCount,
    double childAspectRatio = 1.0,
    double spacing = 8,
    BorderRadius? borderRadius,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerWidget(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        shapeType: ShapeType.rectangular,
      ),
    );
  }

  static Widget buildShimmerRow({
    required int itemCount,
    double itemWidth = 80,
    double itemHeight = 80,
    double spacing = 12,
    BorderRadius? borderRadius,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              right: index == itemCount - 1 ? 0 : spacing,
            ),
            child: ShimmerWidget(
              width: itemWidth,
              height: itemHeight,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              shapeType: ShapeType.rectangular,
            ),
          ),
        ),
      ),
    );
  }
}

enum ShapeType { rectangular, circular }
