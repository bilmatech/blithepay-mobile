import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_bloc.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_event.dart';
import 'package:blithepay/features/fees/presentation/bloc/payment_bloc/payment_state.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/features/students/data/models/view_invoice_model.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_state.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_body.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentConfirmationView extends StatefulWidget {
  final String invoiceId;
  final String studentId;
  final Set<String> feesItemIds;

  const PaymentConfirmationView({
    super.key,
    required this.invoiceId,
    required this.studentId,
    required this.feesItemIds,
  });

  @override
  State<PaymentConfirmationView> createState() =>
      _PaymentConfirmationViewState();
}

class _PaymentConfirmationViewState extends State<PaymentConfirmationView> {
  PaymentMethod? _method;

  @override
  void initState() {
    super.initState();

    // Load invoice as before
    context.read<InvoiceBloc>().add(
      GetInvoiceByIdViewEvent(
        invoiceId: widget.invoiceId,
        feesItemIds: widget.feesItemIds,
      ),
    );

    // Initialize PaymentBloc with empty selection until user chooses fees
    context.read<PaymentBloc>().add(
      InitializePayment(invoiceId: widget.invoiceId, selectedFeeIds: {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        if (state.status == PaymentStatus.onlineReady &&
            state.paymentUrl != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaystackWebView(url: state.paymentUrl!),
            ),
          );

          if (!mounted) return;

          if (result == true) {
            context.go('/linked-students');

            context.read<InvoiceBloc>().add(
              GetInvoiceEvent(studentId: widget.studentId, refresh: true),
            );
          }
        }

        if (state.status == PaymentStatus.success) {
          if (!mounted) return;
          context.go('/linked-students');

          context.read<InvoiceBloc>().add(
            GetInvoiceEvent(studentId: widget.studentId, refresh: true),
          );
        }

        if (state.status == PaymentStatus.failure) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Payment failed')),
          );
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: const BackArrowButtonIcon(),
          title: const Text('Pay Fees'),
          centerTitle: true,
        ),
        body: BlocBuilder<InvoiceBloc, InvoiceState>(
          builder: (context, state) {
            if (state is InvoiceByIdLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InvoiceByIdViewLoaded) {
              return _buildContent(context, state.invoice);
            }

            if (state is InvoiceByIdError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ViewInvoiceModel invoice) {
    final subtotal = invoice.subtotalAmount;
    final vat = invoice.vatAmount;
    final lateFee = _isLateFeeApplicable(invoice) ? invoice.lateFeeAmount : 0.0;
    final total = subtotal + vat + lateFee;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: StudentCard(data: invoice.toStudentCardData()),
              ),
              const SizedBox(height: 16),
              _buildFeeDetails(invoice),
              const SizedBox(height: 16),
              _buildFeeSummary(subtotal, vat, lateFee, total),
              const SizedBox(height: 24),
              _paymentMethods(),
              const SizedBox(height: 24),
              _payButton(invoice, widget.invoiceId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeDetails(ViewInvoiceModel invoice) {
    final items = invoice.items;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(height: 1, color: AppColors.border);
          }
          final item = items[index ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.name ?? '', style: AppTextStyles.bodyRegular),
                Text(item.amountFormatted, style: AppTextStyles.bodyRegular),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeeSummary(
    double subtotal,
    double vat,
    double lateFee,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', subtotal),
          _summaryRow('VAT', vat),
          if (lateFee > 0) _summaryRow('Late Fee Payment', lateFee),
          const Divider(height: 20),
          _summaryRow('Total Payable', total, isBold: true),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    return Column(
      children: [
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
          subtitle: 'Secure card payment',
          icon: Icons.credit_card,
          selected: _method == PaymentMethod.card,
          onTap: () => setState(() => _method = PaymentMethod.card),
        ),
      ],
    );
  }

  Widget _payButton(ViewInvoiceModel invoice, String invoiceId) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, paymentState) {
        final feeIds = invoice.items
            .map((e) => e.id)
            .whereType<String>() // removes nulls
            .toSet();

        return PrimaryButton(
          label: _method == PaymentMethod.wallet
              ? 'Pay with Wallet'
              : 'Continue to Card Payment',
          isEnabled: _method != null,
          isLoading:
              paymentState.status == PaymentStatus.onlineInitializing ||
              paymentState.status == PaymentStatus.walletInProgress,
          onPressed: () {
            if (_method == PaymentMethod.wallet) {
              context.read<PaymentBloc>().add(
                InitializePayment(invoiceId: invoiceId, selectedFeeIds: feeIds),
              );

              _showPinBottomSheet(invoice);
            } else {
              context.read<PaymentBloc>().add(
                InitializeOnlinePayment(
                  invoiceId: invoiceId,
                  selectedFeeIds: feeIds,
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showPinBottomSheet(ViewInvoiceModel invoice) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            return PinBottomSheetContent(
              isLoading: state.status == PaymentStatus.pinVerifying,
              errorMessage: state.message,
              onSubmit: (pin) async {
                context.read<PaymentBloc>().add(VerifyPin(pin));
              },
              onForgotPin: () {
                context.push(AppRoutes.setupOtp);
              },
            );
          },
        );
      },
    );
  }

  bool _isLateFeeApplicable(ViewInvoiceModel invoice) {
    if (invoice.deadline != null) {
      return DateTime.now().isAfter(invoice.deadline!);
    }
    return false;
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
}

class PaystackWebView extends StatefulWidget {
  final String url;

  const PaystackWebView({super.key, required this.url});

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            // Detect payment completion redirect
            if (url.contains('success') ||
                url.contains('callback') ||
                url.contains('payment-complete')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            // Detect cancel
            if (url.contains('cancel')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: WebViewWidget(controller: controller),
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
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 200,
//                   child: StudentCard(student: widget.payload.student),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildFeeDetails(),
//                 const SizedBox(height: 16),
//                 _buildFeeSummary(),
//                 const SizedBox(height: 24),
//                 PaymentMethodTile(
//                   title: 'Wallet',
//                   subtitle: 'Pay using wallet balance',
//                   icon: Icons.account_balance_wallet_outlined,
//                   selected: _method == PaymentMethod.wallet,
//                   onTap: () => setState(() => _method = PaymentMethod.wallet),
//                 ),
//                 const SizedBox(height: 12),
//                 PaymentMethodTile(
//                   title: 'Debit Card',
//                   subtitle: 'Secure card payment via Paystack',
//                   icon: Icons.credit_card,
//                   selected: _method == PaymentMethod.card,
//                   onTap: () => setState(() => _method = PaymentMethod.card),
//                 ),
//                 //  const Spacer(),
//                 const SizedBox(height: 24),

//                 PrimaryButton(
//                   label: _method == PaymentMethod.wallet
//                       ? 'Pay with Wallet'
//                       : 'Continue to Card Payment',
//                   isEnabled: _method != null,
//                   onPressed: _handlePayment,
//                 ),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
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
// bool get _isLateFeeApplicable {
//   final dueDate = widget.payload.invoice.dueAt; // DateTime
//   final now = DateTime.now();
//   return now.isAfter(dueDate);
// }

// double get _lateFee =>
//     _isLateFeeApplicable
//         ? double.tryParse(widget.payload.latePaymentFees) ?? 0
//         : 0;

//   double get _feesTotal => widget.payload.total.toDouble();

//   double get _totalPayable => _feesTotal + _lateFee;

//   Widget _buildFeeSummary() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         children: [
//           _summaryRow('Subtotal', _feesTotal),
//           const SizedBox(height: 6),
//           _summaryRow('Late Fee Payment', _lateFee),
//           const Divider(height: 20),
//           _summaryRow('Total Payable', _totalPayable, isBold: true),
//         ],
//       ),
//     );
//   }

//   Widget _summaryRow(String label, double amount, {bool isBold = false}) {
//     final style = isBold ? AppTextStyles.bodyLarge : AppTextStyles.bodyRegular;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: style),
//         Text(Helpers.formatCurrency(amount), style: style),
//       ],
//     );
//   }

//   void _handlePayment() {
//     if (_method == PaymentMethod.wallet) {
//       _showPinBottomSheet();
//     } else {
//       // context.push(AppRoutes.cardPaymentWebView, extra: widget.payload);
//     }
//   }

//   void _showPinBottomSheet() {
//     final scaffoldContext = context; // <- capture this

//     showModalBottomSheet(
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
//               final feeIds = widget.payload.fees.map((e) => e.id).toList();

//               context.read<FeesBloc>().add(
//                 PayWithWalletEvent(widget.payload.invoice.id, feeIds),
//               );
//             }

//             if (state is WalletPaymentSuccess) {
//               // parent page context
//               Navigator.pop(context); // close bottom sheet first

//               // delay navigation slightly to allow pop to complete
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 context.go(
//                   AppRoutes.feeSuccess,
//                   extra: {'payload': widget.payload, 'paymentData': state.data},
//                 );
//               });
//             }

//             if (state is WalletPaymentFailure) {
//               Navigator.pop(context);

//               ScaffoldMessenger.of(
//                 scaffoldContext,
//               ).showSnackBar(SnackBar(content: Text(state.message)));
//             }
//           },
//           child: const PinBottomSheetContent(),
//         );
//         ;
//       },
//     );
//   }
// }

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
