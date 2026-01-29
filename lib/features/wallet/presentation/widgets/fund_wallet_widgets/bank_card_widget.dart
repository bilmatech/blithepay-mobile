import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:blithepay/features/wallet/presentation/widgets/fund_wallet_widgets/account_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankCardWidget extends StatelessWidget {
  const BankCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Icon and Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.border,
                    ),
                    child: const Icon(Icons.account_balance_rounded, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bank Name", style: AppTextStyles.bodySmall),
                        SizedBox(height: 2),
                        Text(
                          (state is WalletLoaded)
                              ? state.wallet.tag
                              : "No Bank Selected",
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AccountDetailsWidget(
                accountName: (state is WalletLoaded)
                    ? state.wallet.name
                    : 'No Name',
                acctNo: (state is WalletLoaded)
                    ? state.wallet.address
                    : '0000000000',
              ),
            ],
          ),
        );
      },
    );
  }
}
