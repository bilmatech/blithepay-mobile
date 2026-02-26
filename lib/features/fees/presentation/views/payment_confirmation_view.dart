import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_event.dart';
import 'package:blithepay/features/fees/presentation/bloc/fees_state.dart';
import 'package:blithepay/features/fees/presentation/views/fees_breakdown_view.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_body.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PaymentConfirmationView extends StatefulWidget {
  final PaymentPayload payload;

  const PaymentConfirmationView({super.key, required this.payload});

  @override
  State<PaymentConfirmationView> createState() =>
      _PaymentConfirmationViewState();
}

class _PaymentConfirmationViewState extends State<PaymentConfirmationView> {
  PaymentMethod? _method;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Pay Fees'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: StudentCard(student: widget.payload.student),
                ),
                const SizedBox(height: 16),
                _buildFeeDetails(),
                const SizedBox(height: 16),
                _buildFeeSummary(),
                const SizedBox(height: 24),
                PaymentMethodTile(
                  title: 'Wallet',
                  subtitle: 'Pay using wallet balance',
                  icon: Icons.account_balance_wallet_outlined,
                  selected: _method == PaymentMethod.wallet,
                  onTap: () => setState(() => _method = PaymentMethod.wallet),
                ),
                const SizedBox(height: 12),
                PaymentMethodTile(
                  title: 'Debit Card',
                  subtitle: 'Secure card payment via Paystack',
                  icon: Icons.credit_card,
                  selected: _method == PaymentMethod.card,
                  onTap: () => setState(() => _method = PaymentMethod.card),
                ),
                //  const Spacer(),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: _method == PaymentMethod.wallet
                      ? 'Pay with Wallet'
                      : 'Continue to Card Payment',
                  isEnabled: _method != null,
                  onPressed: _handlePayment,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeDetails() {
    final feeItems = widget.payload.fees;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Column(
        children: List.generate(feeItems.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(height: 1, color: AppColors.border);
          }
          final item = feeItems[index ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.name, style: AppTextStyles.bodyRegular),
                Text(
                  item.amountInNaira ??
                      Helpers.formatCurrency(item.amount.toDouble()),
                  style: AppTextStyles.bodyRegular,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  bool get _isLateFeeApplicable {
    final dueDate = widget.payload.invoice.dueAt; // DateTime
    final now = DateTime.now();
    return now.isAfter(dueDate);
  }

  double get _lateFee => _isLateFeeApplicable
      ? double.tryParse(widget.payload.latePaymentFees) ?? 0
      : 0;

  double get _feesTotal => widget.payload.total.toDouble();

  double get _totalPayable => _feesTotal + _lateFee;

  Widget _buildFeeSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', _feesTotal),
          const SizedBox(height: 6),
          if (_lateFee > 0) _summaryRow('Late Fee Payment', _lateFee),
          const Divider(height: 20),
          _summaryRow('Total Payable', _totalPayable, isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isBold = false}) {
    final style = isBold ? AppTextStyles.bodyLarge : AppTextStyles.bodyRegular;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(Helpers.formatCurrency(amount), style: style),
      ],
    );
  }

  void _handlePayment() {
    if (_method == PaymentMethod.wallet) {
      _showPinBottomSheet();
    } else {
      // context.push(AppRoutes.cardPaymentWebView, extra: widget.payload);
    }
  }

  void _showPinBottomSheet() {
    final scaffoldContext = context; // <- capture this

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) {
        return BlocListener<FeesBloc, FeesState>(
          listener: (context, state) {
            if (state is PinVerified) {
              final feeIds = widget.payload.fees.map((e) => e.id).toList();

              context.read<FeesBloc>().add(
                PayWithWalletEvent(widget.payload.invoice.id, feeIds),
              );
            }

            if (state is WalletPaymentSuccess) {
              // parent page context
              Navigator.pop(context); // close bottom sheet first

              // delay navigation slightly to allow pop to complete
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(
                  AppRoutes.feeSuccess,
                  extra: {'payload': widget.payload, 'paymentData': state.data},
                );
              });
            }

            if (state is WalletPaymentFailure) {
              Navigator.pop(context);

              ScaffoldMessenger.of(
                scaffoldContext,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: const PinBottomSheetContent(),
        );
        ;
      },
    );
  }
}
// class PaymentConfirmationView extends StatefulWidget {
//   final PaymentPayload payload;

//   const PaymentConfirmationView({super.key, required this.payload});

//   @override
//   State<PaymentConfirmationView> createState() =>
//       _PaymentConfirmationViewState();
// }

// class _PaymentConfirmationViewState extends State<PaymentConfirmationView> {
//   PaymentMethod? _method;

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: AppBar(title: const Text('Pay Fees'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 200,
//               child: StudentCard(student: widget.payload.student),
//             ),
//             const SizedBox(height: 16),
//             _buildFeeDetails(),
//             const SizedBox(height: 16),

//             _buildFeeSummary(),
//             const SizedBox(height: 24),

//             PaymentMethodTile(
//               title: 'Wallet',
//               subtitle: 'Pay using wallet balance',
//               icon: Icons.account_balance_wallet_outlined,
//               selected: _method == PaymentMethod.wallet,
//               onTap: () => setState(() => _method = PaymentMethod.wallet),
//             ),
//             const SizedBox(height: 12),
//             PaymentMethodTile(
//               title: 'Debit Card',
//               subtitle: 'Secure card payment via Paystack',
//               icon: Icons.credit_card,
//               selected: _method == PaymentMethod.card,
//               onTap: () => setState(() => _method = PaymentMethod.card),
//             ),

//             const Spacer(),

//             PrimaryButton(
//               label: _method == PaymentMethod.wallet
//                   ? 'Pay with Wallet'
//                   : 'Continue to Card Payment',
//               isEnabled: _method != null,
//               onPressed: _handlePayment,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeeDetails() {
//     final feeItems = widget.payload.fees;

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.border),
//         borderRadius: BorderRadius.circular(8),
//         color: AppColors.surface,
//       ),
//       child: Column(
//         children: List.generate(feeItems.length * 2 - 1, (index) {
//           if (index.isOdd) {
//             return const Divider(height: 1, color: AppColors.border);
//           }
//           final item = feeItems[index ~/ 2];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(item.name, style: AppTextStyles.bodyRegular),
//                 Text(
//                   item.amountInNaira ??
//                       Helpers.formatCurrency(item.amount.toDouble()),
//                   style: AppTextStyles.bodyRegular,
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   void _handlePayment() {
//     if (_method == PaymentMethod.wallet) {
//       _showPinBottomSheet(context);
//     } else {
//       //  context.push(AppRoutes.cardPaymentWebView, extra: widget.payload);
//     }
//   }

//   Future<void> _showPinBottomSheet(BuildContext context) {
//     return showModalBottomSheet(
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       context: context,
//       builder: (_) {
//         return BlocListener<FeesBloc, FeesState>(
//           listener: (context, state) {
//             if (state is PinVerified) {
//               Navigator.pop(context);
//               context.go(AppRoutes.feeSuccess, extra: widget.payload);
//             }

//             if (state is FeesError) {
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text(state.message)));
//             }
//           },
//           child: const PinBottomSheetContent(),
//         );
//       },
//     );
//   }

//   Widget _buildFeeSummary() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('Total', style: AppTextStyles.bodyLarge),
//           Text(
//             Helpers.formatCurrency(widget.payload.total.toDouble()),
//             style: AppTextStyles.bodyLarge,
//           ),
//         ],
//       ),
//     );
//   }
// }

class PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethod { wallet, card }
