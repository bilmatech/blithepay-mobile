import 'package:blithepay/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;

  const BottomPanel({
    super.key,
    required this.child,
    required this.maxHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(top: false, child: SingleChildScrollView(child: child)),
      ),
    );
  }
}
