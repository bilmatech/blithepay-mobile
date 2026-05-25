import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/loaders/shimmer_table_loader.dart';

class WalletTransactionsView extends StatefulWidget {
  const WalletTransactionsView({super.key});

  @override
  State<WalletTransactionsView> createState() => _WalletTransactionsViewState();
}

class _WalletTransactionsViewState extends State<WalletTransactionsView> {
  final ScrollController _scrollController = ScrollController();

  String? currentFilter;
  String? currentSort;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final state = context.read<WalletTransactionBloc>().state;

      if (state is WalletTransactionLoaded &&
          state.nextPage != null &&
          !state.isFetchingMore) {
        context.read<WalletTransactionBloc>().add(
          GetTransactionsEvent(page: state.nextPage!, limit: 20),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Wallet Transactions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Column(
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Today:',
            //       style: AppTextStyles.bodyMedium.copyWith(
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //     Row(
            //       children: [
            //         // Filter button with search
            //         AppOutlinedIconButton(
            //           onPressed: () => showFilterPopup<String>(
            //             context: context,
            //             items: [
            //               'Successful',
            //               'Failed',
            //               'Pending',
            //               'Withdrawal',
            //               'Fee Payment',
            //               'Deposit',
            //             ],
            //             selectedValue: currentFilter,
            //             onItemSelected: (value) =>
            //                 setState(() => currentFilter = value),
            //             enableSearch: false,
            //           ),
            //           label: 'Filter',
            //           icon: Icons.tune,
            //         ),
            //         const SizedBox(width: 8),

            //         // Sort button without search
            //         AppOutlinedIconButton(
            //           onPressed: () => showFilterPopup<String>(
            //             context: context,
            //             items: [
            //               'A-Z',
            //               'Z-A',
            //               'Highest - Lowest',
            //               'Lowest - Highest',
            //               'Most Recent',
            //               'Oldest',
            //             ],
            //             selectedValue: currentSort,
            //             onItemSelected: (value) =>
            //                 setState(() => currentSort = value),
            //             enableSearch: false, // no search for sort
            //           ),
            //           label: 'Sort by',
            //           icon: Icons.sort,
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
                builder: (context, state) {
                  if (state is WalletTransactionLoading) {
                    return const ShimmerTableLoader();
                  }

                  if (state is WalletTransactionError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is WalletTransactionLoaded) {
                    return state.transactions.isEmpty
                        ? const Center(
                            child: Text('No wallet Transaction available.'),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<WalletTransactionBloc>().add(
                                GetTransactionsEvent(
                                  page: 1,
                                  limit: 20,
                                  refresh: true,
                                ),
                              );
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  state.transactions.length +
                                  (state.isFetchingMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index < state.transactions.length) {
                                  final transaction = state.transactions[index];
                                  return TransactionContainer(
                                    transaction: transaction,
                                  );
                                }

                                // Bottom loader
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
