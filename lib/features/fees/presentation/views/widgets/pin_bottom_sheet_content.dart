import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_event.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PinBottomSheetContent extends StatefulWidget {
  const PinBottomSheetContent({super.key});

  @override
  State<PinBottomSheetContent> createState() => _PinBottomSheetContentState();
}

class _PinBottomSheetContentState extends State<PinBottomSheetContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Enter Payment PIN',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => SizedBox(
                width: 60,
                height: 60,
                child: TextField(
                  key: UniqueKey(), // avoids duplicate GlobalKey
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) => _onOtpChanged(index, v),
                  style: AppTextStyles.h3,
                  decoration: InputDecoration(
                    counter: const Offstage(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // close bottom sheet
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.push(
                  AppRoutes.setupOtp,
                  extra: {
                    'email': 'fghgh@gmail.com',
                    'flow': OtpFlow.forgotPassword,
                    'pop': true,
                  },
                );
              });
            },
            child: Text(
              'Forgot PIN? Reset',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'BlithePay Secure Numeric Keypad',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirm Payment',
            onPressed: () {
              final pin = _controllers.map((c) => c.text).join();
              if (pin.length == 4) Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
