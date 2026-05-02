import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberField<T> extends StatelessWidget {
  final TextEditingController controller;

  final T? selectedOption;
  final List<T> options;

  final String Function(T)? optionLabel;

  final bool isBeneficiaryListVisible;

  final ValueChanged<String>? onChanged;
  final VoidCallback onBeneficiariesToggle;
  final ValueChanged<T>? onOptionSelected;

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.selectedOption,
    this.options = const [],
    this.optionLabel,
    required this.isBeneficiaryListVisible,
    this.onChanged,
    required this.onBeneficiariesToggle,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          /// OPTION SELECTOR (network / provider / etc.) - Only show if options provided
          if (options.isNotEmpty) ...[
            SizedBox(
              width: 60,
              child: InkWell(
                onTap: () => _showOptionPicker(context),
                child: Center(
                  child: Text(
                    optionLabel?.call(selectedOption as T) ?? 'Select',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 45, color: AppColors.primary),
          ],

          /// PHONE INPUT
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              ],
              decoration: InputDecoration(
                hintText: '080 0000 0000',
                border: InputBorder.none,
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                enabledBorder: InputBorder.none,
              ),
            ),
          ),

          /// TOGGLE
          GestureDetector(
            onTap: onBeneficiariesToggle,
            child: Icon(
              isBeneficiaryListVisible
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOptionPicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: options.map((option) {
              final isSelected = option == selectedOption;

              return ListTile(
                title: Text(optionLabel?.call(option) ?? option.toString()),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  onOptionSelected?.call(option);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
// class PhoneNumberField extends StatelessWidget {
//   final TextEditingController controller;
//   final AirtimeNetwork network;
//   final bool isBeneficiaryListVisible;
//   final VoidCallback onBeneficiariesToggle;

//   const PhoneNumberField({
//     super.key,
//     required this.controller,
//     required this.network,
//     required this.isBeneficiaryListVisible,
//     required this.onBeneficiariesToggle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.primary, width: 1.3),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       child: Row(
//         children: [
//           // Network selector button
//           SizedBox(
//             width: 50,
//             child: InkWell(
//               onTap: () => _showNetworkPicker(context),
//               child: Center(
//                 child: Text(
//                   _networkLabel(network),
//                   style: const TextStyle(
//                     color: Color(0xFF061657),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Divider
//           Container(width: 1, height: 45, color: AppColors.primary),
//           // Phone number input
//           Expanded(
//             child: TextField(
//               controller: controller,
//               onChanged: (value) {
//                 context.read<AirtimeBloc>().add(AirtimePhoneChanged(value));
//               },
//               style: AppTextStyles.bodyRegular,
//               keyboardType: TextInputType.phone,
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
//               ],

//               decoration: InputDecoration(
//                 hintText: '080 0000 0000',
//                 hintStyle: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textTertiary,
//                 ),
//                 filled: true,
//                 fillColor: AppColors.white,
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(color: AppColors.border),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),

//                 prefixIconConstraints: const BoxConstraints(
//                   minWidth: 0,
//                   minHeight: 0,
//                 ),
//               ),

//               // decoration: const InputDecoration(
//               //   border: InputBorder.none,
//               //   hintText: '080 0000 0000',
//               //   hintStyle: TextStyle(
//               //     color: Color(0xFF9EA1AA),
//               //     fontSize: 18,
//               //     fontWeight: FontWeight.w500,
//               //     letterSpacing: 0,
//               //   ),
//               //   // isDense: true,
//               //   contentPadding: EdgeInsets.zero,
//               // ),
//             ),
//           ),
//           // Beneficiaries toggle button
//           GestureDetector(
//             onTap: onBeneficiariesToggle,
//             child: Icon(
//               isBeneficiaryListVisible
//                   ? Icons.keyboard_arrow_up_rounded
//                   : Icons.keyboard_arrow_down_rounded,
//               color: Colors.black,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showNetworkPicker(BuildContext context) {
//     return showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: AppColors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (sheetContext) {
//         return SafeArea(
//           top: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: AirtimeNetwork.values.map((option) {
//                 final isSelected = option == network;

//                 return ListTile(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
//                   //  leading: _NetworkLogo(network: option, size: 42),
//                   title: Text(
//                     _networkLabel(option),
//                     style: const TextStyle(
//                       color: Color(0xFF061657),
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 0,
//                     ),
//                   ),
//                   trailing: isSelected
//                       ? const Icon(
//                           Icons.check_circle,
//                           color: AppColors.primary,
//                           size: 25,
//                         )
//                       : null,
//                   onTap: () {
//                     // context.read<AirtimeBloc>().add(
//                     //   AirtimeNetworkSelected(option),
//                     // );
//                     // Navigator.pop(sheetContext);
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _networkLabel(AirtimeNetwork network) {
//     return switch (network) {
//       AirtimeNetwork.mtn => 'MTN',
//       AirtimeNetwork.glo => 'Glo',
//       AirtimeNetwork.airtel => 'Airtel',
//     };
//   }
// }
