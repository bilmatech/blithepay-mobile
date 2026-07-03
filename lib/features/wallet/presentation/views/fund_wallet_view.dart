import 'package:blithepay/core/constants/app_strings.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/wallet/presentation/widgets/fund_wallet_widgets/account_details_widget.dart';
import 'package:blithepay/features/wallet/presentation/widgets/fund_wallet_widgets/bank_card_widget.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';


class FundWalletView extends StatefulWidget {
  const FundWalletView({super.key});

  @override
  State<FundWalletView> createState() => _FundWalletViewState();
}

class _FundWalletViewState extends State<FundWalletView> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fund Wallet'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.transferAccountDetails,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.fundyouBilthePay,
                style: AppTextStyles.bodyRegular,
              ),
              const SizedBox(height: 32),

              // Bank Info
              const BankCardWidget(),

              const SizedBox(height: 24),

              // Info Box
              const InfoBoxWidget(
                message:
                    "Transfer to this account and your wallet will be credited instantly",
              ),

              const SizedBox(height: 32),

              // Done Button
              PrimaryButton(
                label: 'Transfer Done',
                onPressed: () {
                  context.read<WalletBloc>().add(const FetchWalletDataEvent(forceRefresh: true));
                  context.read<DashboardBloc>().add(const FetchDashboardData(forceRefresh: true));
                  context.go(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
