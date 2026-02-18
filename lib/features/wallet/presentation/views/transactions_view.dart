import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/app_outlined_icon_button.dart';
import 'package:blithepay/shared/widgets/inputs/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../../../../shared/widgets/loaders/shimmer_table_loader.dart';
import '../../../../core/constants/app_text_styles.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  // String _searchQuery = '';
  String? currentFilter;
  String? currentSort;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const GetTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const ShimmerTableLoader();
          } else if (state is TransactionsLoaded) {
            final transactions = state.transactions;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    // TextField(
                    //   onChanged: (value) =>
                    //       setState(() => _searchQuery = value),
                    //   decoration: InputDecoration(
                    //     hintText: 'Search transactions...',
                    //     prefixIcon: const Icon(Icons.search),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 16),

                    // Filter & Sort buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            // Filter button with search
                            AppOutlinedIconButton(
                              onPressed: () => showFilterPopup<String>(
                                context: context,
                                items: [
                                  'Successful',
                                  'Failed',
                                  'Pending',
                                  'Withdrawal',
                                  'Fee Payment',
                                  'Deposit',
                                ],
                                selectedValue: currentFilter,
                                onItemSelected: (value) =>
                                    setState(() => currentFilter = value),
                                enableSearch: false,
                              ),
                              label: 'Filter',
                              icon: Icons.tune,
                            ),
                            const SizedBox(width: 8),

                            // Sort button without search
                            AppOutlinedIconButton(
                              onPressed: () => showFilterPopup<String>(
                                context: context,
                                items: [
                                  'A-Z',
                                  'Z-A',
                                  'Highest - Lowest',
                                  'Lowest - Highest',
                                  'Most Recent',
                                  'Oldest',
                                ],
                                selectedValue: currentSort,
                                onItemSelected: (value) =>
                                    setState(() => currentSort = value),
                                enableSearch: false, // no search for sort
                              ),
                              label: 'Sort by',
                              icon: Icons.sort,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    // Transaction table
                  ],
                ),
              ),
            );
          } else if (state is WalletError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
