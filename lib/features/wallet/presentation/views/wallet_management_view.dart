import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/features/wallet/presentation/widgets/quick_action_button.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({super.key});

  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView> {
  bool _isLoading = false;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Wallet Management'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              if (_isLoading)
                ShimmerWidget(height: 140, borderRadius: BorderRadius.circular(4))
              else
                Container(
                  decoration: BoxDecoration(
                    //color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _balanceVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),
                          Text(
                            _balanceVisible ? 'N200,000.32' : '•••••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Current Balance',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.1,
                              ), // semi-transparent glass color
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
                              onPressed: () {
                                context.push(AppRoutes.fundWallet);
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Fund Wallet'),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),

                      // Bottom-right image
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/dashboard.png',
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Quick Actions
              const QuickActionButtons(),
              const SizedBox(height: 24),

              if (_isLoading)
                ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ShimmerWidget(height: 60, borderRadius: BorderRadius.circular(8)),
                )
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionContainer(transaction: transaction);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final transactions = [
  WalletTransactionModel(
    amount: '300',
    status: 'success',
    id: 'cmlqkb0qr003e0vpczzqhii7l',
    name: 'Tuition fee',
    walletId: 'cmljgzu8w00070vp3yy5udkc8',
    fees: '10',
    netAmount: '198',
    reference: '1771330263964dmgr24pmlqkayzg',
    type: 'Deposit',
    flow: '',
    transactionAt: '2026-02-17T12:11:06.242Z',
    processedAt: '2026-02-17T12:11:07.027Z',
    isDeleted: false,
    createdAt: '2026-02-17T12:11:07.028Z',
    updatedAt: '2026-02-17T12:11:06.243Z',
  ),
  WalletTransactionModel(
    amount: '200',
    status: 'success',
    id: 'cmlqkb0qr003e0vpczzqhii7l',
    name: 'Tuition fee',
    walletId: 'cmljgzu8w00070vp3yy5udkc8',
    fees: '10',
    netAmount: '',
    reference: '1771330263964dmgr24pmlqkayzg',
    type: 'Deposit',
    flow: '',
    transactionAt: '2026-02-17T12:11:06.242Z',
    processedAt: '2026-02-17T12:11:07.027Z',
    isDeleted: false,
    createdAt: '2026-02-17T12:11:07.028Z',
    updatedAt: '2026-02-17T12:11:06.243Z',
  ),
];
