import 'package:blithepay/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TopOffGrid extends StatelessWidget {
  final int selectedAmountKobo;
  final ValueChanged<int> onAmountSelected;

  const TopOffGrid({
    super.key,
    required this.selectedAmountKobo,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    const amounts = [5000, 10000, 20000, 50000, 100000, 200000];

    return GridView.builder(
      itemCount: amounts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 44,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final amountKobo = amounts[index];
        final isSelected = amountKobo == selectedAmountKobo;

        return _TopOffChip(
          amountKobo: amountKobo,
          isSelected: isSelected,
          onTap: () => onAmountSelected(amountKobo),
        );
      },
    );
  }
}

class _TopOffChip extends StatelessWidget {
  final int amountKobo;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopOffChip({
    required this.amountKobo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final whole = amountKobo ~/ 100;
    final label = whole >= 1000 ? '₦${whole ~/ 1000}k' : '₦$whole';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
