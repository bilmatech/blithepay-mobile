import 'package:flutter/material.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../widgets/service_form_widgets.dart';

class ElectricityServiceView extends StatelessWidget {
  const ElectricityServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Electricity'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ServiceForm(
          title: 'Electricity',
          recipientLabel: 'Meter Number',
          recipientHint: 'Enter meter number',
          providerLabel: 'Select distributor',
          providerOptions: const ['PHCN', 'EKEDC', 'AEDC', 'IKEDC'],
          showPlanSelector: true,
          plans: const [
            ServicePlan(
              title: 'Prepaid',
              description: 'Load tokens instantly',
              price: '₦3,000',
            ),
            ServicePlan(
              title: 'Postpaid',
              description: 'Pay your monthly bill',
              price: '₦8,500',
            ),
            ServicePlan(
              title: 'Bulk Token',
              description: 'Large quantity purchase',
              price: '₦15,000',
            ),
          ],
          presetAmounts: const [3000, 5000, 8500, 10000, 15000, 20000],
          walletBalance: 'Wallet: ₦5,000',
          actionButtonLabel: 'Continue',
          actionSubtitle: 'Confirm electricity payment',
          serviceIcon: Icons.flash_on,
        ),
      ),
    );
  }
}
