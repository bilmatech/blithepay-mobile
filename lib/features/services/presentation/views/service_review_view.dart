import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/features/services/presentation/bloc/service_bloc/service_bloc.dart';
import 'package:blithepay/features/services/presentation/views/shared/success_panel.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';

class ServiceReviewView extends StatefulWidget {
  const ServiceReviewView({super.key});

  @override
  State<ServiceReviewView> createState() => _ServiceReviewViewState();
}

class _ServiceReviewViewState extends State<ServiceReviewView> {
  PaymentMethod? _method = PaymentMethod.wallet;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ServiceBloc>().state;

    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Service'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BodyLg('Payment Details'),

                      VSpaceBase(),

                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Column(
                          children: [
                            const BodyLg('TOTAL AMOUNT'),

                            Text(
                              '₦${(state.amountKobo / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _row('Service Name', 'Airtime'),

                            _row('Recipient Number', state.recipient),

                            _row(
                              'Amount',
                              '₦${(state.amountKobo / 100).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Payment Method',
                        style: AppTextStyles.bodyLarge,
                      ),

                      const SizedBox(height: 12),

                      PaymentMethodTile(
                        title: 'Pay with Wallet',
                        subtitle: 'AVAILABLE BALANCE',
                        amount:
                            '₦${(state.availableBalanceKobo / 100).toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_outlined,
                        selected: _method == PaymentMethod.wallet,
                        onTap: () {
                          setState(() {
                            _method = PaymentMethod.wallet;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      PaymentMethodTile(
                        title: 'Pay with Card',
                        subtitle:
                            'Secure card, bank transfer, and USSD options via Paystack.',
                        icon: Icons.credit_card,
                        selected: _method == PaymentMethod.card,
                        onTap: () {
                          setState(() {
                            _method = PaymentMethod.card;
                          });
                        },
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: PrimaryButton(
                          label: 'Pay',
                          onPressed: () {
                            if (_method == PaymentMethod.wallet) {
                              _showPin(context);
                            } else {
                              // card flow
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(value)],
      ),
    );
  }

  void _showPin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return PinBottomSheetContent(
          isLoading: false,
          errorMessage: '',
          onSubmit: (pin) async {
            Navigator.pop(context);

            _showSuccess(context);
          },
          onForgotPin: () {},
        );
      },
    );
  }

  void _showSuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SuccessPanel(
          title: 'Payment Successful',
          description: 'Your transaction was successful.',
          onDownloadReceipt: () {},
          onGoHome: () {
            Navigator.pop(context);
            context.pop();
          },
        );
      },
    );
  }
}
