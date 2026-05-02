import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart'
    show AppLocalDataSource;
import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:blithepay/shared/widgets/layouts/app_button.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';

import 'package:blithepay/shared/widgets/layouts/bottom_navigation.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_dashboard_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class DashboardView extends StatelessWidget {
  final Widget child;

  const DashboardView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Hide bottom nav only for individual service screens (e.g., /service/airtime, /service/data)
    // Keep bottom nav visible for the main services screen (/service)
    final hideBottomNavigation = location.contains('/service/');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: child),
      bottomNavigationBar: hideBottomNavigation
          ? null
          : BottomNavigationWidget(currentRoute: location),
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
                    StreamBuilder<UserModel?>(
                      stream: context.read<AppLocalDataSource>().userStream,
                      builder: (context, snapshot) {
                        final user = snapshot.data;

                        final userName = user != null
                            ? '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                  .trim()
                            : state.dashboard.userName;

                        final avatarUrl =
                            user?.profileImage ?? state.dashboard.avatarUrl;

                        return DashboardHeader(
                          greeting: state.dashboard.greeting,
                          userName: userName,
                          avatarUrl: avatarUrl,
                        );
                      },
                    ),
                    const VSpaceXl(),
                    FinancialSummaryCard(
                      totalOutstanding: state.dashboard.totalOutstanding,
                      nextDueDate: state.dashboard.nextDueDate,
                      walletBalance: state.dashboard.walletBalance,
                      selectedChild: state.dashboard.selectedChildName,
                    ),
                    // Quick Services Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const HeadingMd('Quick Services'),
                        AppTextButton(
                          label: 'See All',
                          onPressed: () => context.push(AppRoutes.service),
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                    const VSpaceBase(),
                    SizedBox(height: 100, child: _buildServicesList(context)),
                    const VSpaceXl(),

                    // Activity Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const HeadingMd('Activity'),
                        AppTextButton(
                          label: 'See History',
                          onPressed: () {},
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                    const VSpaceBase(),

                    // Empty state
                    const Center(
                      child: BodyMd(
                        'No activity yet',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const VSpaceXxl(),
                    // Transactions section using WalletTransactionBloc
                    // BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
                    //   builder: (context, walletState) {
                    //     if (walletState is WalletTransactionLoading) {
                    //       return const RecentTransactionsShimmer();
                    //     }
                    //     if (walletState is WalletTransactionError) {
                    //       return Center(
                    //         child: Text('Error: ${walletState.message}'),
                    //       );
                    //     }
                    //     if (walletState is WalletTransactionLoaded) {
                    //       if (walletState.transactions.isEmpty) {
                    //         return const Text('No transactions yet.');
                    //       }
                    //       return RecentTransactions(
                    //         transactions: walletState.transactions,
                    //       );
                    //     }
                    //     return const SizedBox();
                    //   },
                    // ),
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

Widget _buildServicesList(BuildContext context) {
  final services = [
    ('Airtime', Icons.phone_android, AppRoutes.airtimeService),
    ('Data', Icons.wifi, AppRoutes.dataService),
    ('Cable/TV', Icons.tv, AppRoutes.cableTvService),
    ('Electricity', Icons.flash_on, AppRoutes.electricityService),
  ];

  return Row(
    children: services.map((service) {
      return Expanded(
        child: _buildServiceCard(context, service.$1, service.$2, service.$3),
      );
    }).toList(),
  );
}

Widget _buildServiceCard(
  BuildContext context,
  String name,
  IconData icon,
  String route,
) {
  return GestureDetector(
    onTap: () => GoRouter.of(context).push(route),
    child: Column(
      children: [
        Container(
          width: AppSpacing.huge,
          height: AppSpacing.huge,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSpacing.iconXs),
        ),
        const VSpaceBase(),
        BodyMd(name, color: AppColors.textPrimary, textAlign: TextAlign.center),
      ],
    ),
  );
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
        const VSpaceBase(),

        // Transaction list shimmer
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => const VSpaceMd(),
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
                            const VSpaceXs(),
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
