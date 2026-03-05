import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/quick_action_buttons.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_event.dart';

import 'package:blithepay/shared/widgets/layouts/bottom_navigation.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_dashboard_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class DashboardView extends StatelessWidget {
  final Widget child;

  const DashboardView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationWidget(currentRoute: location),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Only fetch summary from WalletBloc
    context.read<WalletBloc>().add(const FetchWalletDataEvent());

    // Fetch transactions separately
    context.read<WalletTransactionBloc>().add(GetTransactionsEvent());
    context.read<DashboardBloc>().add(const FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) return const ShimmerDashboardLoader();

        if (state is DashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                const FetchDashboardData(forceRefresh: true),
              );
              context.read<WalletBloc>().add(const FetchWalletDataEvent());
              context.read<WalletTransactionBloc>().add(
                GetTransactionsEvent(refresh: true),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(
                      greeting: state.dashboard.greeting,
                      userName: state.dashboard.userName,
                      avatarUrl: state.dashboard.avatarUrl,
                    ),
                    const SizedBox(height: 24),
                    FinancialSummaryCard(
                      totalOutstanding: state.dashboard.totalOutstanding,
                      nextDueDate: state.dashboard.nextDueDate,
                      walletBalance: state.dashboard.walletBalance,
                      selectedChild: state.dashboard.selectedChildName,
                    ),
                    const SizedBox(height: 24),
                    const QuickActionButtons(),
                    const SizedBox(height: 24),

                    // Transactions section using WalletTransactionBloc
                    BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
                      builder: (context, walletState) {
                        if (walletState is WalletTransactionLoading) {
                          return const RecentTransactionsShimmer();
                        }
                        if (walletState is WalletTransactionError) {
                          return Center(
                            child: Text('Error: ${walletState.message}'),
                          );
                        }
                        if (walletState is WalletTransactionLoaded) {
                          if (walletState.transactions.isEmpty) {
                            return const Text('No transactions yet.');
                          }
                          return RecentTransactions(
                            transactions: walletState.transactions,
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class RecentTransactionsShimmer extends StatelessWidget {
  const RecentTransactionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final shimmerBaseColor = Colors.grey.shade300;
    final shimmerHighlightColor = Colors.grey.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Shimmer.fromColors(
          baseColor: shimmerBaseColor,
          highlightColor: shimmerHighlightColor,
          child: Container(
            height: 16,
            width: 150,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Transaction list shimmer
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) {
            return Shimmer.fromColors(
              baseColor: shimmerBaseColor,
              highlightColor: shimmerHighlightColor,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, // important: solid color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 120,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 12,
                              width: 80,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(height: 14, width: 70, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 50, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
