import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showPasswordToggle;
  final int? maxLines;
  final int minLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final Widget? prefix;
  final FocusNode? focusNode;
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.validator,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.enabled = true,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.suffixIcon,
    this.prefix,
    this.focusNode,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          style: AppTextStyles.bodyRegular,
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),

            prefixIcon: widget.prefix,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            suffixIcon: widget.showPasswordToggle
                ? GestureDetector(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  )
                : widget.suffixIcon,
          ),
          // InputDecoration(
          //   hintText: widget.hint,
          //   hintStyle: AppTextStyles.bodySmall.copyWith(
          //     color: AppColors.textTertiary,
          //   ),
          //   suffixIcon: widget.showPasswordToggle
          //       ? GestureDetector(
          //           onTap: () => setState(() => _obscureText = !_obscureText),
          //           child: Icon(
          //             _obscureText
          //                 ? Icons.visibility_off_outlined
          //                 : Icons.visibility_outlined,
          //             color: AppColors.textSecondary,
          //           ),
          //         )
          //       : widget.suffixIcon,
          // ),
        ),
      ],
    );
  }
}
