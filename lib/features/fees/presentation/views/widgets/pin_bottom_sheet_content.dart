import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/nemeric_keyboard.dart';
import 'package:blithepay/shared/widgets/bottom_sheets/bottom_sheet_container.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

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
    _controllers = List.generate(
      widget.pinLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.pinLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
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
      title: 'Enter Payment PIN',
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
            child: NumericKeypad(
              onKeyTap: _onKeyPressed,
              onDelete: _onDeletePressed,
            ),
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
                await widget.onSubmit(pin);
              }
            },
          ),
        ],
      ),
    );
  }
}
// class PinBottomSheetContent extends StatefulWidget {
//   const PinBottomSheetContent({super.key});

//   @override
//   State<PinBottomSheetContent> createState() => _PinBottomSheetContentState();
// }

// class _PinBottomSheetContentState extends State<PinBottomSheetContent> {
//   late final List<TextEditingController> _controllers;
//   late final List<FocusNode> _focusNodes;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(4, (_) => TextEditingController());
//     _focusNodes = List.generate(4, (_) => FocusNode());
//   }

//   @override
//   void dispose() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     for (final f in _focusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }

//   void _onKeyPressed(String value) {
//     for (int i = 0; i < _controllers.length; i++) {
//       if (_controllers[i].text.isEmpty) {
//         _controllers[i].text = value;
//         if (i < _focusNodes.length - 1) _focusNodes[i + 1].requestFocus();
//         break;
//       }
//     }
//   }

//   void _onDeletePressed() {
//     for (int i = _controllers.length - 1; i >= 0; i--) {
//       if (_controllers[i].text.isNotEmpty) {
//         _controllers[i].clear();
//         _focusNodes[i].requestFocus();
//         break;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomSheetContainer(
//       title: 'Enter Payment PIN',
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(
//                 4,
//                 (index) => SizedBox(
//                   width: 60,
//                   height: 60,
//                   child: TextField(
//                     controller: _controllers[index],
//                     focusNode: _focusNodes[index],
//                     readOnly: true,
//                     showCursor: false,
//                     textAlign: TextAlign.center,
//                     maxLength: 1,
//                     obscureText: true,
//                     style: AppTextStyles.h3,
//                     decoration: InputDecoration(
//                       counter: const Offstage(),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Center(
//               child: GestureDetector(
//                 onTap: () async {
//                   final userSession = await AppLocalDataSourceImpl(
//                     const FlutterSecureStorage(),
//                   ).getSession();

//                   Navigator.pop(context); // close bottom sheet
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     context.push(
//                       AppRoutes.setupOtp,
//                       extra: {
//                         'email': userSession?.user?.email ?? '',
//                         'flow': OtpFlow.forgotPassword,
//                         'pop': true,
//                       },
//                     );
//                   });
//                 },
//                 child: Text(
//                   'Forgot PIN? Reset',
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.success,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 18),
//             NumericKeypad(onKeyTap: _onKeyPressed, onDelete: _onDeletePressed),
//             const SizedBox(height: 24),
//             BlocListener<PaymentBloc, PaymentState>(
//               listener: (context, state) {
//                 if (state.status == PaymentStatus.success) {
//                   Navigator.pop(context); // CLOSE SHEET
//                 }

//                 if (state.status == PaymentStatus.failure &&
//                     state.message != null) {
//                   Navigator.pop(context); // CLOSE SHEET

//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text(state.message!)));
//                 }
//               },
//               child: BlocBuilder<PaymentBloc, PaymentState>(
//                 builder: (context, state) {
//                   return PrimaryButton(
//                     label: 'Confirm Payment',
//                     isLoading:
//                         state.status == PaymentStatus.pinVerifying ||
//                         state.status == PaymentStatus.walletInProgress,
//                     onPressed: () {
//                       final pin = _controllers.map((c) => c.text).join();
//                       if (pin.length == 4) {
//                         context.read<PaymentBloc>().add(VerifyPin(pin));
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PinBottomSheetContent extends StatefulWidget {
//   const PinBottomSheetContent({super.key});

//   @override
//   State<PinBottomSheetContent> createState() => _PinBottomSheetContentState();
// }

// class _PinBottomSheetContentState extends State<PinBottomSheetContent> {
//   late final List<TextEditingController> _controllers;
//   late final List<FocusNode> _focusNodes;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(4, (_) => TextEditingController());
//     _focusNodes = List.generate(4, (_) => FocusNode());
//   }

//   @override
//   void dispose() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     for (final f in _focusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }

//   // void _onOtpChanged(int index, String value) {
//   //   if (value.isNotEmpty && index < 3) {
//   //     _focusNodes[index + 1].requestFocus();
//   //   } else if (value.isEmpty && index > 0) {
//   //     _focusNodes[index - 1].requestFocus();
//   //   }
//   // }

//   void _onKeyPressed(String value) {
//     for (int i = 0; i < _controllers.length; i++) {
//       if (_controllers[i].text.isEmpty) {
//         _controllers[i].text = value;
//         if (i < _focusNodes.length - 1) {
//           _focusNodes[i + 1].requestFocus();
//         }
//         break;
//       }
//     }
//   }

//   void _onDeletePressed() {
//     for (int i = _controllers.length - 1; i >= 0; i--) {
//       if (_controllers[i].text.isNotEmpty) {
//         _controllers[i].clear();
//         _focusNodes[i].requestFocus();
//         break;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: 16,
//         right: 16,
//         top: 24,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Center(
//             child: SizedBox(
//               width: 40,
//               height: 4,
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   color: Colors.grey,
//                   borderRadius: BorderRadius.all(Radius.circular(4)),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Enter Payment PIN',
//             style: AppTextStyles.bodyLarge.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: List.generate(
//               4,
//               (index) => SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: TextField(
//                   controller: _controllers[index],
//                   focusNode: _focusNodes[index],
//                   readOnly: true, // IMPORTANT
//                   showCursor: false,
//                   textAlign: TextAlign.center,
//                   maxLength: 1,
//                   obscureText: true,
//                   style: AppTextStyles.h3,
//                   decoration: InputDecoration(
//                     counter: const Offstage(),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: AppColors.primary,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           GestureDetector(
//             onTap: () async {
//               final userSession = await AppLocalDataSourceImpl(
//                 const FlutterSecureStorage(),
//               ).getSession();

//               Navigator.pop(context); // close bottom sheet
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 context.push(
//                   AppRoutes.setupOtp,
//                   extra: {
//                     'email': userSession?.user?.email ?? '',
//                     'flow': OtpFlow.forgotPassword,
//                     'pop': true,
//                   },
//                 );
//               });
//             },
//             child: Text(
//               'Forgot PIN? Reset',
//               style: AppTextStyles.bodySmall.copyWith(
//                 color: AppColors.success,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           NumericKeypad(onKeyTap: _onKeyPressed, onDelete: _onDeletePressed),

//           const SizedBox(height: 24),
//           Text(
//             'BlithePay Secure Numeric Keypad',
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           BlocBuilder<FeesBloc, FeesState>(
//             builder: (context, state) {
//               final isLoading = state is FeesLoading;

//               return PrimaryButton(
//                 label: 'Confirm Payment',
//                 isLoading: isLoading,
//                 onPressed: () {
//                   final pin = _controllers.map((c) => c.text).join();
//                   if (pin.length != 4) return;

//                   // Dispatch verifyPin with invoice info
//                   final payload = context.read<PaymentConfirmationPayload>();
//                   context.read<FeesBloc>().add(
//                     VerifyPinEvent(
//                       pin,
//                       invoiceId: payload.invoiceId,
//                       feeItemIds: payload.fees.map((f) => f.id).toList(),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
// }
