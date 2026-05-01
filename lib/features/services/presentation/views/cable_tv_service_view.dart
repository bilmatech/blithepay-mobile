import 'package:flutter/material.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../widgets/service_form_widgets.dart';

class CableTvServiceView extends StatelessWidget {
  const CableTvServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Cable/TV'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ServiceForm(
          title: 'Cable/TV',
          recipientLabel: 'Smartcard Number',
          recipientHint: 'Enter smartcard number',
          providerLabel: 'Select provider',
          providerOptions: const ['DStv', 'GOtv', 'Startimes'],
          showPlanSelector: true,
          plans: const [
            ServicePlan(
              title: 'Basic Package',
              description: 'Good for local channels',
              price: '₦3,500',
            ),
            ServicePlan(
              title: 'Classic Package',
              description: 'More channels and movies',
              price: '₦5,500',
            ),
            ServicePlan(
              title: 'Premium Package',
              description: 'All channels included',
              price: '₦9,500',
            ),
          ],
          presetAmounts: const [3500, 5500, 9500, 12000, 15000, 20000],
          walletBalance: 'Wallet: ₦5,000',
          actionButtonLabel: 'Continue',
          actionSubtitle: 'Pay for subscription',
          serviceIcon: Icons.tv,
        ),
      ),
    );
  }
}
