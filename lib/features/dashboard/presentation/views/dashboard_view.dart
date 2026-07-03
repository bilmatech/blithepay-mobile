import 'package:blithepay/features/vas/core/presentation/bloc/services_cubit/services_cubit.dart';
import 'package:blithepay/features/vas/core/presentation/bloc/services_cubit/services_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/widgets/layouts/bottom_navigation.dart';
import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_dashboard_loader.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/service_card.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/transaction/presentation/bloc/transaction_state.dart';

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
        if (state is DashboardLoading || state is DashboardInitial) {
          return const ShimmerDashboardLoader();
        }

        if (state is DashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load dashboard',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(
                        const FetchDashboardData(forceRefresh: true),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

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
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  elevation: 0,
                  backgroundColor: AppColors.background,
                  title: StreamBuilder<UserModel?>(
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
                ),
                // const VSpaceXl(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: FinancialSummaryCard(
                      totalOutstanding: state.dashboard.totalOutstanding,
                      nextDueDate: state.dashboard.nextDueDate,
                      walletBalance: state.dashboard.walletBalance,
                      selectedChild: state.dashboard.selectedChildName,
                    ),
                  ),
                ),
                // // Quick Services Section
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Quick Actions',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
                // Services Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: BlocBuilder<ServicesCubit, ServicesState>(
                    builder: (context, state) {
                      final filteredServices = state.toDisplayList(
                        includeMore: true,
                      );

                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 6,
                              childAspectRatio: 0.8,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final service = filteredServices[index];
                          return ServiceCard(
                            service: service,
                            onTap: () {
                              context.push(service.route, extra: service);
                            },
                          );
                        }, childCount: filteredServices.length),
                      );
                    },
                  ),
                ), // Activity Title
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Activity', style: AppTextStyles.bodyLarge),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.transactions),
                          child: Text(
                            'See History',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Recent Activity (dynamic list from API). Tapping opens details.
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<WalletTransactionBloc, WalletTransactionState>(
                      builder: (context, txState) {
                        if (txState is WalletTransactionLoading) {
                          return const RecentTransactionsShimmer();
                        }
                        if (txState is WalletTransactionError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                txState.message,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ),
                          );
                        }
                        if (txState is WalletTransactionLoaded) {
                          final txList = txState.transactions;
                          if (txList.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No transactions yet',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          // Display exactly 3 items on the home page as requested
                          final displayList = txList.take(3).toList();
                          return Column(
                            children: List.generate(displayList.length, (index) {
                              final tx = displayList[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == displayList.length - 1 ? 0 : 12,
                                ),
                                child: TransactionContainer(transaction: tx),
                              );
                            }),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                // Padding at bottom
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 20),
                  sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
              ],
            ),
          );
        }

        return const ShimmerDashboardLoader();
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
