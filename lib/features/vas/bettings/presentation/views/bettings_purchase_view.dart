import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:flutter/material.dart';

class BettingsPurchaseView extends StatelessWidget {
  const BettingsPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const Text('Services'),
        centerTitle: true,
      ),
      body: const Center(child: Text('Betting')),
    );
  }
}
