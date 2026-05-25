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
        mainAxisExtent: 52,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final amountKobo = amounts[index];
        final isSelected = amountKobo == selectedAmountKobo;

        return OutlinedButton(
          onPressed: () => onAmountSelected(amountKobo),
          style: OutlinedButton.styleFrom(
            foregroundColor: isSelected ? AppColors.white : AppColors.primary,
            backgroundColor: isSelected
                ? AppColors.primary
                : const Color(0xFFF7F8FB),
            side: BorderSide.none,
            elevation: isSelected ? 6 : 0,
            shadowColor: const Color(0x4415457F),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₦',
                style: TextStyle(
                  color: isSelected ? AppColors.white : const Color(0xFF061657),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${amountKobo ~/ 100}',
                style: TextStyle(
                  color: isSelected ? AppColors.white : const Color(0xFF061657),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
