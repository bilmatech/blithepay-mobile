import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/bottom_sheets/bottom_sheet_container.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/nemeric_keyboard.dart';

class PinBottomSheetContent extends StatefulWidget {
  final int pinLength;
  final Future<void> Function(String pin) onSubmit; // Kept your exact signature
  final VoidCallback? onForgotPin;
  final bool isLoading;
  final String? errorMessage;

  const PinBottomSheetContent({
    super.key,
    this.pinLength = 4,
    required this.onSubmit,
    this.onForgotPin,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<PinBottomSheetContent> createState() => _PinBottomSheetContentState();
}

class _PinBottomSheetContentState extends State<PinBottomSheetContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.pinLength, (_) => TextEditingController());
    _focusNodes = List.generate(widget.pinLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _clearPin() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  void _onKeyPressed(String value) {
    if (widget.isLoading) return; // Freeze entry while submitting

    for (int i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isEmpty) {
        _controllers[i].text = value;
        if (i < _focusNodes.length - 1) {
          _focusNodes[i + 1].requestFocus();
        } else {
          // AUTO-SUBMIT: Last field populated, evaluate string instantly
          final fullPin = _controllers.map((c) => c.text).join();
          if (fullPin.length == widget.pinLength) {
            _clearPin();
            widget.onSubmit(fullPin);
          }
        }
        break;
      }
    }
  }

  void _onDeletePressed() {
    if (widget.isLoading) return;

    for (int i = _controllers.length - 1; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        _controllers[i].clear();
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      title: 'Enter Transaction PIN',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.pinLength,
              (index) => SizedBox(
                width: 60,
                height: 60,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  readOnly: true,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ),

          if (widget.onForgotPin != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.isLoading ? null : widget.onForgotPin,
              child: Text(
                'Forgot PIN? Reset',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          Opacity(
            opacity: widget.isLoading ? 0.6 : 1.0,
            child: NumericKeypad(onKeyTap: _onKeyPressed, onDelete: _onDeletePressed),
          ),

          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],

          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Confirm Payment',
            isLoading: widget.isLoading,
            onPressed: () async {
              final pin = _controllers.map((c) => c.text).join();
              if (pin.length == widget.pinLength) {
                _clearPin();
                await widget.onSubmit(pin);
              }
            },
          ),
        ],
      ),
    );
  }
}
