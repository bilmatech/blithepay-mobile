import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/features/wallet/presentation/widgets/quick_action_button.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/app_outlined_icon_button.dart';
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
    return AppScaffold(
      appBar: AppBar(title: const Text('Wallet Management'), centerTitle: true),
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tuesday, 11 July, 2026.',
                                  style: TextStyle(
                                    color: Colors.white,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
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
                            const SizedBox(height: 16),
                          ],
                        ),
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

              // Recent Transactions
              Row(
                children: [
                  Text(
                    'Recent Transactions:',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  AppOutlinedIconButton(
                    label: 'Filter',
                    icon: Icons.tune,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  AppOutlinedIconButton(
                    label: 'Sort by',
                    icon: Icons.sort,
                    borderRadius: 8,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                Container(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.grey.shade200,
                    ),
                    dataRowHeight: 36,
                    headingRowHeight: 36,
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    columns: const [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Method',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            const Expanded(
                              child: Text(
                                '11-09-25. 11:15',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              // handle row click
                            },
                          ),
                          DataCell(
                            const Expanded(
                              child: Text(
                                'N300,000.00',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                          DataCell(
                            const Expanded(
                              child: Text(
                                'Wallet',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                          DataCell(
                            const Expanded(
                              child: Text(
                                'Withdrawal',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            const Expanded(
                              child: Text(
                                '11-09-25. 11:15',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                          DataCell(
                            const Expanded(
                              child: Text(
                                'N300,000.00',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                          DataCell(
                            const Expanded(
                              child: Text(
                                'Wallet',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                          DataCell(
                            const Expanded(
                              child: Text(
                                'Fee Payment',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: DataTable(
              //     headingRowColor: WidgetStateProperty.resolveWith(
              //       (states) => Colors.grey.shade200,
              //     ),
              //     dataRowHeight: 42,
              //     headingRowHeight: 42,
              //     columnSpacing: 24,
              //     horizontalMargin: 24,
              //     columns: const [
              //       DataColumn(label: Text('Date')),
              //       DataColumn(label: Text('Amount')),
              //       DataColumn(label: Text('Method')),
              //       DataColumn(label: Text('Type')),
              //     ],
              //     rows: const [
              //       DataRow(
              //         cells: [
              //           DataCell(
              //             Text(
              //               '11-09-25. 11:15',
              //               style: TextStyle(fontSize: 12),
              //             ),
              //           ),
              //           DataCell(
              //             Text('N300,000.00', style: TextStyle(fontSize: 12)),
              //           ),
              //           DataCell(
              //             Text('Wallet', style: TextStyle(fontSize: 12)),
              //           ),
              //           DataCell(
              //             Text('Withdrawal', style: TextStyle(fontSize: 12)),
              //           ),
              //         ],
              //       ),
              //       DataRow(
              //         cells: [
              //           DataCell(
              //             Text(
              //               '11-09-25. 11:15',
              //               style: TextStyle(fontSize: 12),
              //             ),
              //           ),
              //           DataCell(
              //             Text('N300,000.00', style: TextStyle(fontSize: 12)),
              //           ),
              //           DataCell(
              //             Text('Wallet', style: TextStyle(fontSize: 12)),
              //           ),
              //           DataCell(
              //             Text('Fee Payment', style: TextStyle(fontSize: 12)),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
