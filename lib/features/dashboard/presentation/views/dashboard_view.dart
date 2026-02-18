import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/dashboard/presentation/models/dashboard_model.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/quick_action_buttons.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:blithepay/shared/widgets/layouts/bottom_navigation.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_dashboard_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    Future.microtask(() {
      context.read<DashboardBloc>().add(const FetchDashboardData());
      context.read<WalletBloc>().add(const FetchWalletDataEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const ShimmerDashboardLoader();
        }

        if (state is DashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                const FetchDashboardData(forceRefresh: true),
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
                    RecentTransactions(
                      transactions: state.dashboard.transactions,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is DashboardError) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const FetchDashboardData());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardHeader(
                      greeting: 'Good morning',
                      userName: 'Test User',
                      avatarUrl: '',
                    ),
                    const SizedBox(height: 24),
                    const FinancialSummaryCard(
                      totalOutstanding: '',
                      nextDueDate: '',
                      walletBalance: '₦0.00',
                      selectedChild: '',
                    ),
                    const SizedBox(height: 24),
                    const QuickActionButtons(),
                    const SizedBox(height: 24),
                    RecentTransactions(
                      transactions: DashboardModel.mock().transactions,
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
