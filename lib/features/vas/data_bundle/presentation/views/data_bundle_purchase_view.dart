import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart'
    as vas_models;
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/core/presentation/views/service_review_view.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/service_phone_section.dart';
import 'package:blithepay/features/vas/core/utils/balance_helper.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:blithepay/features/vas/airtime/presentation/widgets/amount_entry_card.dart' show AmountEntryCard;
import 'package:blithepay/features/vas/core/presentation/widgets/contact_beneficiaries_row.dart';
import 'package:flutter/material.dart';

// ── Root view ─────────────────────────────────────────────────────────────────

class DataBundlePurchaseView extends StatelessWidget {
  final ServiceEntity? service;

  const DataBundlePurchaseView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final initialBalance = getWalletBalanceKobo(context);

    return BlocProvider(
      create: (context) => ServiceBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: service?.id,
        config: ServiceConfig(
          title: 'Data',
          recipientLabel: 'Recipient Phone',
          recipientHint: 'Enter phone number',
          providerLabel: 'Select Network',
          providerOptions: const ['MTN', 'GLO', 'Airtel', '9mobile'],
          plans: const [],
          presetAmounts: const [],
          availableBalanceKobo: initialBalance,
        ),
      ),
      child: const _DataBundleView(),
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class _DataBundleView extends StatefulWidget {
  const _DataBundleView();

  @override
  State<_DataBundleView> createState() => _DataBundleViewState();
}

class _DataBundleViewState extends State<_DataBundleView> {
  TextEditingController? _phoneController;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<ServiceBloc>().state;
    _phoneController = TextEditingController(text: initialState.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: true,
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const BodySm('Services'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<WalletBloc, WalletState>(
              listener: (context, walletState) {
                if (walletState is WalletLoaded) {
                  final balanceKobo = (walletState.wallet.balance * 100).round();
                  context
                      .read<ServiceBloc>()
                      .add(ServiceBalanceUpdated(balanceKobo));
                }
              },
            ),
            BlocListener<DashboardBloc, DashboardState>(
              listener: (context, dashboardState) {
                if (dashboardState is DashboardLoaded) {
                  final rawBalance = dashboardState.dashboard.walletBalance;
                  final cleanString =
                      rawBalance.replaceAll(RegExp(r'[^\d.]'), '');
                  final doubleValue = double.tryParse(cleanString);
                  if (doubleValue != null) {
                    final balanceKobo = (doubleValue * 100).round();
                    context
                        .read<ServiceBloc>()
                        .add(ServiceBalanceUpdated(balanceKobo));
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              final hasSelectedProvider = state.selectedProvider.isNotEmpty;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Bundle',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Network picker (mirrors airtime circles) ───────────
                    _buildNetworkSection(context, state),

                    const SizedBox(height: 28),

                    // ── Contact Beneficiaries Section ──
                    if (state.contactBeneficiaries.isNotEmpty) ...[
                      ContactBeneficiariesRow(
                        beneficiaries: state.contactBeneficiaries,
                        isFetchingMore: state.isFetchingMoreContactBeneficiaries,
                        onLoadMore: () {
                          context.read<ServiceBloc>().add(
                                ServiceContactBeneficiariesRequested(),
                              );
                        },
                        onTap: (b) {
                          context.read<ServiceBloc>().add(
                                ServiceContactBeneficiarySelected(b),
                              );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Everything below only visible after network pick ───
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: hasSelectedProvider ? 1.0 : 0.35,
                      child: AbsorbPointer(
                        absorbing: !hasSelectedProvider,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Phone number ───────────────────────────────
                            const Text(
                              'Recipient',
                              style: AppTextStyles.headingSmall,
                            ),
                            const SizedBox(height: 10),
                            ServicePhoneSection(
                              state: state,
                              phoneController:
                                  _ensurePhoneController(state),
                            ),

                            const SizedBox(height: 28),

                            // ── Package selector ───────────────────────────
                            _DataPackageSection(state: state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Network section — same circular style as airtime ──────────────────────

  Widget _buildNetworkSection(BuildContext context, ServiceState state) {
    final providerLabel = state.config.providerLabel;

    final List<vas_models.ServiceProviderModel> providers =
        state.providers.isNotEmpty
            ? state.providers
            : state.config.providerOptions
                .map((name) =>
                    vas_models.ServiceProviderModel(id: name, name: name))
                .toList();

    // ── Loading ──
    if (state.isProvidersLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            providerLabel,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ShimmerWidget.buildShimmerRow(
              itemCount: 4,
              itemWidth: 64,
              itemHeight: 64,
              spacing: 16,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ],
      );
    }

    // ── Error ──
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            providerLabel,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              state.errorMessage!,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                final sid = state.selectedProviderId;
                if (sid != null && sid.isNotEmpty) {
                  context
                      .read<ServiceBloc>()
                      .add(ServiceProvidersRequested(sid));
                }
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    // ── Idle / loaded ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          providerLabel,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 76,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: providers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final provider = providers[index];
                final isSelected = provider.name == state.selectedProvider;

                return GestureDetector(
                  onTap: () {
                    context.read<ServiceBloc>().add(
                          ServiceProviderSelected(
                            provider.name,
                            // When real providers come from API, pass id
                            // so bloc auto-dispatches ServiceProductsRequested
                            providerId: state.providers.isNotEmpty
                                ? provider.id
                                : null,
                          ),
                        );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border.withValues(alpha: 0.5),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: provider.logo != null &&
                                  provider.logo!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    provider.logo!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderLetter(provider.name),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.primary
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : _buildPlaceholderLetter(provider.name),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderLetter(String name) {
    final cleanName = name.trim().toUpperCase();
    final displayLetter = cleanName.isNotEmpty ? cleanName[0] : '?';
    return Text(
      displayLetter,
      style: TextStyle(
        fontWeight: FontWeight.w900,
        color: AppColors.primary.withValues(alpha: 0.6),
        fontSize: 20,
      ),
    );
  }

  TextEditingController _ensurePhoneController(ServiceState state) {
    if (_phoneController != null && _phoneController!.text != state.phoneNumber) {
      _phoneController!.text = state.phoneNumber;
      _phoneController!.selection = TextSelection.collapsed(offset: state.phoneNumber.length);
    }
    return _phoneController ??=
        TextEditingController(text: state.phoneNumber);
  }
}

// ── Package section (loads after network is selected) ─────────────────────────

class _DataPackageSection extends StatefulWidget {
  final ServiceState state;

  const _DataPackageSection({required this.state});

  @override
  State<_DataPackageSection> createState() => _DataPackageSectionState();
}

class _DataPackageSectionState extends State<_DataPackageSection> {
  ServicePlanCategory? _activeCategory;
  TextEditingController? _amountController;

  @override
  void dispose() {
    _amountController?.dispose();
    super.dispose();
  }

  TextEditingController _ensureAmountController(ServiceState state) {
    final formatted = _formatAmount(state.amountKobo);
    if (_amountController != null && _amountController!.text != formatted) {
      _amountController!.text = formatted;
      _amountController!.selection = TextSelection.collapsed(offset: formatted.length);
    }
    return _amountController ??= TextEditingController(text: formatted);
  }

  String _formatAmount(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }

  List<(int globalIndex, vas_models.ServiceProductModel plan)>
      get _visiblePlans {
    final allPlans = widget.state.products;
    if (allPlans.isEmpty) return const [];
    return [
      for (var i = 0; i < allPlans.length; i++)
        if (_activeCategory == null ||
            allPlans[i].category == _activeCategory)
          (i, allPlans[i]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    // ── No network selected yet – show nothing ──
    if (state.selectedProvider.isEmpty) return const SizedBox.shrink();

    // ── Packages loading shimmer ──
    if (state.isProductsLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Plan', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShimmerWidget(
                height: 62,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      );
    }

    // ── Packages load error ──
    if (state.products.isEmpty && !state.isProductsLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Plan', style: AppTextStyles.headingSmall),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              state.errorMessage?.isNotEmpty == true
                  ? state.errorMessage!
                  : 'No packages available for ${state.selectedProvider}. Tap Retry to reload.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                final pid = state.selectedProviderId;
                if (pid != null && pid.isNotEmpty) {
                  context
                      .read<ServiceBloc>()
                      .add(ServiceProductsRequested(pid));
                }
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    // ── Loaded: show category tabs + plan list + pay button ──
    final products = state.products;
    final selectedIdx = state.selectedPlanIndex;
    final selectedPlan =
        (selectedIdx != null && selectedIdx >= 0 && selectedIdx < products.length)
            ? products[selectedIdx]
            : null;

    final bool isPhoneValid = state.phoneNumber.trim().length >= 10;
    final bool isPlanValid = selectedPlan != null;
    final bool isFormValid = isPhoneValid && isPlanValid;

    final buttonLabel =
        selectedPlan != null ? 'Pay ${selectedPlan.priceLabel}' : 'Pay';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        const Text('Data Plan', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),

        // ── Category tabs ──────────────────────────────────────────────────
        _CategoryTabBar(
          active: _activeCategory,
          onSelected: (cat) => setState(() => _activeCategory = cat),
        ),

        const SizedBox(height: 12),

        // ── Scrollable plan list ───────────────────────────────────────────
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBF5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _visiblePlans.isEmpty
                ? Center(
                    child: Text(
                      'No plans for this category.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _visiblePlans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final (globalIndex, plan) = _visiblePlans[i];
                      return _PlanCard(
                        plan: plan,
                        isSelected:
                            globalIndex == (state.selectedPlanIndex ?? -1),
                        onTap: () => context
                            .read<ServiceBloc>()
                            .add(ServicePlanSelected(globalIndex)),
                      );
                    },
                  ),
          ),
        ),

        if (selectedPlan != null) ...[
          const SizedBox(height: 20),
          AmountEntryCard(
            controller: _ensureAmountController(state),
            availableBalanceKobo: state.availableBalanceKobo,
            enabled: false,
          ),
        ],

        const SizedBox(height: 20),

        // ── Pay button ─────────────────────────────────────────────────────
        PrimaryButton(
          label: buttonLabel,
          isEnabled: isFormValid,
          onPressed: () => _navigateToReview(context, selectedPlan: selectedPlan),
        ),
      ],
    );
  }

  void _navigateToReview(
    BuildContext context, {
    required vas_models.ServiceProductModel? selectedPlan,
  }) {
    if (selectedPlan == null) return;

    final bloc = context.read<ServiceBloc>();
    final currentState = bloc.state;
    final repo = context.read<ServiceRepository>();

    final args = ServiceReviewArgs(
      title: 'Data',
      amountKobo: selectedPlan.amountKobo,
      recipient: currentState.phoneNumber.trim(),
      providerName: currentState.selectedProvider,
      icon: Icons.wifi_rounded,
      summaryDetails: [
        ServiceReviewDetail(
          label: 'Network',
          value: currentState.selectedProvider,
        ),
        ServiceReviewDetail(
          label: 'Phone Number',
          value: currentState.phoneNumber.trim(),
        ),
        ServiceReviewDetail(label: 'Bundle', value: selectedPlan.name),
        ServiceReviewDetail(label: 'Validity', value: selectedPlan.validity),
        ServiceReviewDetail(label: 'Amount', value: selectedPlan.priceLabel),
      ],
      onPay: (pin) async {
        final token = await repo.verifyPin(pin);
        return repo.purchaseInternet(
          serviceId: bloc.currentServiceId ?? '',
          providerId: currentState.selectedProviderId ??
              currentState.selectedProvider,
          recipient:
              currentState.phoneNumber.replaceAll(RegExp(r'\s+'), ''),
          bundleCode: selectedPlan.bundleCode,
          amountKobo: selectedPlan.amountKobo,
          challengeToken: token,
          contactName: currentState.contactName,
        );
      },
      onCancel: () => bloc.add(ServiceResetRequested()),
    );

    context.push('/service/review', extra: args);
  }
}

// ── Category tab bar ──────────────────────────────────────────────────────────

class _CategoryTabBar extends StatelessWidget {
  final ServicePlanCategory? active;
  final ValueChanged<ServicePlanCategory?> onSelected;

  const _CategoryTabBar({required this.active, required this.onSelected});

  static const _tabs = [
    (null, 'All'),
    (ServicePlanCategory.daily, 'Daily'),
    (ServicePlanCategory.weekly, 'Weekly'),
    (ServicePlanCategory.monthly, 'Monthly'),
    (ServicePlanCategory.yearly, 'Yearly'),
    (ServicePlanCategory.unlimited, 'Unlimited'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _TabChip(
              label: _tabs[i].$2,
              isActive: active == _tabs[i].$1,
              onTap: () => onSelected(_tabs[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF0F1F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final vas_models.ServiceProductModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8EBF5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _RadioDot(isSelected: isSelected),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.validity,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  plan.priceLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;

  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFBBC2D8),
          width: 1.8,
        ),
      ),
      child: isSelected
          ? const Center(
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.white),
            )
          : null,
    );
  }
}
