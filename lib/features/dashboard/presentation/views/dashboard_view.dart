import 'package:blithepay/shared/widgets/app_drawer.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_dashboard_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/navigation/app_routes.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/recent_transactions.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      drawer: const AppDrawer(
        userName: 'Emmanuel Seaman',
        userEmail: 'emmanuel@example.com',
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const ShimmerDashboardLoader();
            } else if (state is DashboardLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        greeting: state.dashboard.greeting,
                        userName: state.dashboard.userName,
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
              );
            } else if (state is DashboardError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedNavIndex,
        onTap: (index) => _handleNavigation(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Fees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.push(AppRoutes.linkedStudents);
        break;
      case 2:
        context.push(AppRoutes.payFees);
        break;
      case 3:
        context.push(AppRoutes.walletManagement);
        break;
    }
  }
}
