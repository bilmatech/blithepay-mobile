import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String) onKeyTap;
  final VoidCallback onDelete;

  const NumericKeypad({
    super.key,
    required this.onKeyTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
        ),
        itemCount: 12,
        itemBuilder: (_, index) {
          if (index == 9) return const SizedBox.shrink();
          if (index == 11) {
            return _KeyButton(
              icon: Icons.backspace_outlined,
              onTap: onDelete,
            );
          }
          final number = index == 10 ? '0' : '${index + 1}';
          return _KeyButton(
            label: number,
            onTap: () => onKeyTap(number),
          );
        },
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: label != null
              ? Text(label!, style: AppTextStyles.h3)
              : Icon(icon, size: 24),
        ),
      ),
    );
  }
}
