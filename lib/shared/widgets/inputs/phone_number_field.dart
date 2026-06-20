import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/services/data/models/beneficiary_model.dart';
import 'package:blithepay/features/services/utils/network_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable phone number input with auto-detected Nigerian network badge on
/// the left and a contact-picker trigger on the right.
///
/// Callers are responsible for:
/// - supplying [detectedNetwork] derived from the typed number (see
///   [detectNigerianNetwork]).
/// - wiring [onContactPickerTap] to open a contact picker sheet.
class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final ServiceNetwork? detectedNetwork;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onContactPickerTap;
  final String hintText;
  final Widget? prefixIcon;

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.detectedNetwork,
    this.onChanged,
    this.onContactPickerTap,
    this.hintText = '080 0000 0000',
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = detectedNetwork != null
        ? networkColor(detectedNetwork!)
        : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          prefixIcon ?? _NetworkBadge(network: detectedNetwork),

          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 1,
            height: 22,
            color: detectedNetwork != null
                ? networkColor(detectedNetwork!).withValues(alpha: 0.35)
                : AppColors.border,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              ],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),

          const SizedBox(width: 8),
          _ContactPickerButton(onTap: onContactPickerTap),
        ],
      ),
    );
  }
}

class _NetworkBadge extends StatelessWidget {
  final ServiceNetwork? network;

  const _NetworkBadge({this.network});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: network == null ? _buildEmpty() : _buildNetwork(network!),
    );
  }

  Widget _buildEmpty() {
    return Container(
      key: const ValueKey('empty'),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.sim_card_outlined,
        color: AppColors.textTertiary,
        size: 18,
      ),
    );
  }

  Widget _buildNetwork(ServiceNetwork net) {
    final color = networkColor(net);
    return Container(
      key: ValueKey(net),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          networkShortLabel(net),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

class _ContactPickerButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ContactPickerButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.contacts_rounded,
          color: AppColors.primary,
          size: 18,
        ),
      ),
    );
  }
}

/// Network brand colour used across the phone field and contact picker.
Color networkColor(ServiceNetwork network) => switch (network) {
  ServiceNetwork.mtn => const Color(0xFFFFC300),
  ServiceNetwork.glo => const Color(0xFF009A44),
  ServiceNetwork.airtel => const Color(0xFFED1C24),
  ServiceNetwork.nineMobile => const Color(0xFF006633),
};
