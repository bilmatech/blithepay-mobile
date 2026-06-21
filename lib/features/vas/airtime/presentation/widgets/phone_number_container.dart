import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/vas/airtime/presentation/widgets/amount_entry_card.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/core/presentation/views/service_review_view.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/service_phone_section.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/top_off_grid.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class PhoneNumberContainer extends StatelessWidget {
  final ServiceState state;
  final TextEditingController phoneController;
  final TextEditingController amountController;

  const PhoneNumberContainer({
    super.key,
    required this.state,
    required this.phoneController,
    required this.amountController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPhoneValid = state.phoneNumber.trim().length >= 10;
    final bool isAmountValid = state.amountKobo > 0;
    final bool isProviderValid = state.selectedProvider.isNotEmpty;
    final bool isFormValid = isPhoneValid && isAmountValid && isProviderValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Recipient section ──────────────────────────────────────────────
        const Text('Recipient', style: AppTextStyles.headingSmall),
        const SizedBox(height: 10),

        ServicePhoneSection(state: state, phoneController: phoneController),

        const SizedBox(height: 28),

        // ── Quick Top-off ──────────────────────────────────────────────────
        const Text('Quick Top-off', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),

        TopOffGrid(
          selectedAmountKobo: state.amountKobo,
          onAmountSelected: (value) {
            amountController.text = _formatAmount(value);
            context.read<ServiceBloc>().add(ServiceAmountSelected(value));
          },
        ),

        const SizedBox(height: 20),

        // ── Amount input ───────────────────────────────────────────────────
        AmountEntryCard(
          controller: amountController,
          availableBalanceKobo: state.availableBalanceKobo,
          onAmountChanged: (value) {
            context.read<ServiceBloc>().add(ServiceAmountSelected(value));
          },
        ),

        const SizedBox(height: 28),

        // ── Pay button ─────────────────────────────────────────────────────
        PrimaryButton(
          label: state.amountKobo > 0
              ? 'Pay ${state.formattedAmount}'
              : 'Pay',
          isEnabled: isFormValid,
          onPressed: () => _navigateToReview(context),
        ),
      ],
    );
  }

  void _navigateToReview(BuildContext context) {
    final bloc = context.read<ServiceBloc>();
    final currentState = bloc.state;
    final repo = context.read<ServiceRepository>();

    final formattedAmount =
        '₦${(currentState.amountKobo / 100).toStringAsFixed(2)}';

    final args = ServiceReviewArgs(
      title: 'Airtime',
      amountKobo: currentState.amountKobo,
      recipient: currentState.phoneNumber.trim(),
      providerName: currentState.selectedProvider,
      icon: Icons.phone_android_rounded,
      summaryDetails: [
        ServiceReviewDetail(
          label: 'Network',
          value: currentState.selectedProvider,
        ),
        ServiceReviewDetail(
          label: 'Phone Number',
          value: currentState.phoneNumber.trim(),
        ),
        ServiceReviewDetail(label: 'Amount', value: formattedAmount),
      ],
      onPay: (pin) async {
        final token = await repo.verifyPin(pin);
        return repo.purchaseAirtime(
          serviceId: bloc.currentServiceId ?? '',
          recipient: currentState.phoneNumber.replaceAll(RegExp(r'\s+'), ''),
          providerId: currentState.selectedProviderId ?? currentState.selectedProvider,
          amountKobo: currentState.amountKobo,
          challengeToken: token,
          contactName: currentState.contactName,
        );
      },
      onCancel: () => bloc.add(ServiceResetRequested()),
    );

    context.push('/service/review', extra: args);
  }

  String _formatAmount(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }
}
