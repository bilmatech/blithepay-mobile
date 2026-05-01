import 'package:blithepay/features/services/presentation/widgets/service_form_widgets.dart';
import 'package:flutter/material.dart';
import '../../../../shared/layouts/app_scaffold.dart';

class AirtimeServiceView extends StatelessWidget {
  const AirtimeServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Airtime'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ServiceForm(
          title: 'Airtime',
          recipientLabel: 'Recipient Phone',
          recipientHint: 'Enter phone number',
          providerLabel: 'Select network',
          providerOptions: const ['MTN', 'GLO', 'Airtel', '9mobile'],
          showPlanSelector: false,
          presetAmounts: const [50, 100, 200, 500, 1000, 2000],
          walletBalance: 'Wallet: ₦5,000',
          actionButtonLabel: 'Continue',
          actionSubtitle: 'Pay with wallet or paystack',
          serviceIcon: Icons.phone_android,
        ),
      ),
    );
  }
}
