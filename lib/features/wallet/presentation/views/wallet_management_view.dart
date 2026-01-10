import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:flutter/material.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({super.key});

  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView> {
  bool _isLoading = true;
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wallet Management'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              if (_isLoading)
                ShimmerWidget(
                  height: 140,
                  borderRadius: BorderRadius.circular(4),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tuesday, 11 July, 2026.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _balanceVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _balanceVisible = !_balanceVisible,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.wallet),
                      label: const Text('Fund Wallet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Fees'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.call_made),
                      label: const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions:',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Filter'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Sort by'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => ShimmerWidget(
                    height: 60,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Method')),
                      DataColumn(label: Text('Type')),
                    ],
                    rows: const [
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '11-09-25. 11:15',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text('N300,000.00', style: TextStyle(fontSize: 12)),
                          ),
                          DataCell(
                            Text('Wallet', style: TextStyle(fontSize: 12)),
                          ),
                          DataCell(
                            Text('Withdrawal', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '11-09-25. 11:15',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text('N300,000.00', style: TextStyle(fontSize: 12)),
                          ),
                          DataCell(
                            Text('Wallet', style: TextStyle(fontSize: 12)),
                          ),
                          DataCell(
                            Text('Fee Payment', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
