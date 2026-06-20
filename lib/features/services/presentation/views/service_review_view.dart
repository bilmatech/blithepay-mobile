import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/services/presentation/views/shared/receipt_services.dart';
import 'package:blithepay/features/services/presentation/widgets/purchase_overlay.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/features/services/presentation/views/shared/success_panel.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';

class ServiceReviewView extends StatefulWidget {
  const ServiceReviewView({super.key});

  @override
  State<ServiceReviewView> createState() => _ServiceReviewViewState();
}

class _ServiceReviewViewState extends State<ServiceReviewView> {
  PaymentMethod? _method = PaymentMethod.wallet;

  @override
  Widget build(BuildContext context) {
    // Read current state values natively via watched state channels
    final state = context.watch<ServiceBloc>().state;
    final dashboardState = context.read<DashboardBloc>().state;

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
                      const VSpaceBase(),
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
                            _row('Service Name', state.config.title),
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
                        amount: dashboardState is DashboardLoaded
                            ? dashboardState.dashboard.walletBalance
                            : null,
                        icon: Icons.account_balance_wallet_outlined,
                        selected: _method == PaymentMethod.wallet,
                        onTap: () =>
                            setState(() => _method = PaymentMethod.wallet),
                      ),
                      const SizedBox(height: 12),
                      PaymentMethodTile(
                        title: 'Pay with Card',
                        subtitle:
                            'Secure card, bank transfer, and USSD options via Paystack.',
                        icon: Icons.credit_card,
                        selected: _method == PaymentMethod.card,
                        onTap: () =>
                            setState(() => _method = PaymentMethod.card),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: PrimaryButton(
                          label: 'Pay',
                          onPressed: () {
                            if (_method == PaymentMethod.wallet) {
                              _showPin(context);
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

  void _showPin(BuildContext parentContext) {
    final serviceBloc = parentContext.read<ServiceBloc>();

    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: serviceBloc,
          child: BlocConsumer<ServiceBloc, ServiceState>(
            listenWhen: (prev, curr) =>
                prev.isProcessing != curr.isProcessing ||
                prev.stage != curr.stage ||
                prev.errorMessage != curr.errorMessage,
            listener: (modalCtx, state) {
              // 1. SUCCESS GUARD
              if (state.stage == ServiceStage.success &&
                  state.transaction != null) {
                Navigator.pop(sheetContext); // Close PIN sheet
                _showSuccess(parentContext, serviceBloc, state.transaction);
                return;
              }

              // 2. ERROR GUARD: If processing stops and there's an error, kick them out to try again
              if (!state.isProcessing &&
                  state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                Navigator.pop(
                  sheetContext,
                ); // Close PIN sheet so they can fix or retry
              }
            },
            builder: (modalCtx, state) {
              return PurchaseProcessingOverlay(
                visible: state.isProcessing,
                child: PinBottomSheetContent(
                  isLoading: state.isProcessing,
                  errorMessage:
                      null, // No longer need to display error inside the modal itself
                  onSubmit: (pin) async {
                    modalCtx.read<ServiceBloc>().add(ServicePinSubmitted(pin));
                  },
                  onForgotPin: () {},
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSuccess(
    BuildContext targetContext,
    ServiceBloc activeBloc,
    dynamic transaction,
  ) {
    showModalBottomSheet(
      context: targetContext,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SuccessPanel(
          title: 'Payment Successful',
          description: 'Your transaction was completed successfully.',
          onDownloadReceipt: () async {
            if (transaction != null) {
              await ReceiptService.download(transaction: transaction);
            }
          },
          onGoHome: () {
            // Wipe data memory clean back to defaults
            activeBloc.add(ServiceResetRequested());

            Navigator.pop(context); // Dismiss success panel
            Navigator.pop(
              targetContext,
            ); // Pop out of ServiceReviewView back to form index
          },
        );
      },
    );
  }
}
