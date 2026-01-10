import 'package:blithepay_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTableLoader extends StatelessWidget {
  final int rowCount;

  const ShimmerTableLoader({
    super.key,
    this.rowCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Container(height: 16, width: 60, color: Colors.white)),
            DataColumn(label: Container(height: 16, width: 80, color: Colors.white)),
            DataColumn(label: Container(height: 16, width: 70, color: Colors.white)),
            DataColumn(label: Container(height: 16, width: 60, color: Colors.white)),
          ],
          rows: List.generate(
            rowCount,
            (index) => DataRow(
              cells: [
                DataCell(Container(height: 16, width: 60, color: Colors.white)),
                DataCell(Container(height: 16, width: 80, color: Colors.white)),
                DataCell(Container(height: 16, width: 70, color: Colors.white)),
                DataCell(Container(height: 16, width: 60, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
