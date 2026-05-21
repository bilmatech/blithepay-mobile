import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountEntryCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<int>? onAmountChanged;
  final String currencySymbol;
  final String label;

  const AmountEntryCard({
    super.key,
    required this.controller,
    this.onAmountChanged,
    this.currencySymbol = '₦',
    this.label = 'ENTER AMOUNT',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary, width: 1.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    Text(
                      currencySymbol,
                      style: const TextStyle(
                        color: Color(0xFF061657),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (value) {
                          final amount = _parseAmountKobo(value);
                          if (amount != null && onAmountChanged != null) {
                            onAmountChanged!(amount);
                          }
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        style: const TextStyle(
                          color: Color(0xFF061657),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  int? _parseAmountKobo(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) return null;
    return (parsed * 100).round();
  }
}
