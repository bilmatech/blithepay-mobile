import 'package:flutter/material.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../widgets/service_form_widgets.dart';

class DataServiceView extends StatelessWidget {
  const DataServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Data Plan'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ServiceForm(
          title: 'Data',
          recipientLabel: 'Recipient Phone',
          recipientHint: 'Enter phone number',
          providerLabel: 'Select network',
          providerOptions: const ['MTN', 'GLO', 'Airtel', '9mobile'],
          showPlanSelector: true,
          plans: const [
            ServicePlan(
              title: 'Basic Data',
              description: '500MB for 1 day',
              price: '₦200',
            ),
            ServicePlan(
              title: 'Daily Plan',
              description: '1GB for 1 day',
              price: '₦500',
            ),
            ServicePlan(
              title: 'Weekly Plan',
              description: '5GB for 7 days',
              price: '₦2,000',
            ),
            ServicePlan(
              title: 'Monthly Plan',
              description: '15GB for 30 days',
              price: '₦5,000',
            ),
          ],
          presetAmounts: const [50, 100, 200, 500, 1000, 2000],
          walletBalance: 'Wallet: ₦5,000',
          actionButtonLabel: 'Continue',
          actionSubtitle: 'Pay with wallet or paystack',
          serviceIcon: Icons.wifi,
        ),
      ),
    );
  }
}
