import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/features/vas/core/utils/balance_helper.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/cable_tv/data/models/cable_tv_models.dart';
import 'package:blithepay/features/vas/core/data/models/cable_tv_beneficiary_model.dart';
import 'package:blithepay/features/vas/cable_tv/presentation/bloc/cable_tv_bloc/cable_tv_bloc.dart';
import 'package:blithepay/features/vas/airtime/presentation/widgets/amount_entry_card.dart' show AmountEntryCard;
import 'package:blithepay/features/vas/core/presentation/views/service_review_view.dart';

// ── Root ──────────────────────────────────────────────────────────────────────

class CableTvPurchaseView extends StatelessWidget {
  final ServiceEntity? service;

  const CableTvPurchaseView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final initialBalance = getWalletBalanceKobo(context);

    return BlocProvider(
      create: (context) => CableTvBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: service?.id,
        availableBalanceKobo: initialBalance,
        recentSmartcards: const [
          CableTvSmartcard(
            id: '1',
            smartcardNumber: '00012345678',
            provider: 'DStv',
            customerName: 'John Doe',
            packageName: 'Compact',
          ),
          CableTvSmartcard(
            id: '2',
            smartcardNumber: '00056789012',
            provider: 'GOtv',
            customerName: 'Jane Smith',
            packageName: 'Max',
          ),
        ],
      )..add(CableTvInitRequested())..add(CableTvBeneficiariesRequested()),
      child: const _CableTvScreen(),
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class _CableTvScreen extends StatefulWidget {
  const _CableTvScreen();

  @override
  State<_CableTvScreen> createState() => _CableTvScreenState();
}

class _CableTvScreenState extends State<_CableTvScreen> {
  TextEditingController? _smartcardCtrl;
  TextEditingController? _amountController;

  @override
  void dispose() {
    _smartcardCtrl?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

  TextEditingController _ensureSmartcardController(CableTvState state) {
    if (_smartcardCtrl != null && _smartcardCtrl!.text != state.smartcardNumber) {
      _smartcardCtrl!.text = state.smartcardNumber;
      _smartcardCtrl!.selection = TextSelection.collapsed(offset: state.smartcardNumber.length);
    }
    return _smartcardCtrl ??= TextEditingController(text: state.smartcardNumber);
  }

  TextEditingController _ensureAmountController(CableTvState state) {
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
                  context.read<CableTvBloc>().add(CableTvBalanceUpdated(balanceKobo));
                }
              },
            ),
            BlocListener<DashboardBloc, DashboardState>(
              listener: (context, dashboardState) {
                if (dashboardState is DashboardLoaded) {
                  final rawBalance = dashboardState.dashboard.walletBalance;
                  final cleanString = rawBalance.replaceAll(RegExp(r'[^\d.]'), '');
                  final doubleValue = double.tryParse(cleanString);
                  if (doubleValue != null) {
                    final balanceKobo = (doubleValue * 100).round();
                    context.read<CableTvBloc>().add(CableTvBalanceUpdated(balanceKobo));
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<CableTvBloc, CableTvState>(
            builder: (context, state) {
              final hasSelectedProvider = state.selectedProvider.isNotEmpty;
              final bool hasValidSmartcardLength = state.smartcardNumber.replaceAll(RegExp(r'[^\d]'), '').length >= 10;
              final bool isLoadingVerification = state.isVerifying && hasValidSmartcardLength;
              final bool isVerified = state.customer != null;
              final bool hasSelectedPackage = state.selectedPackage != null;

              final bool isAmountValid = state.amountKobo > 0;
              final bool isFormValid = isVerified && hasSelectedPackage && isAmountValid && hasSelectedProvider && !state.isVerifying;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cable TV',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Provider selection section ──
                    _buildProviderSection(context, state),

                    const SizedBox(height: 28),

                    // ── Cable TV Beneficiaries Section ──
                    if (state.beneficiaries.isNotEmpty) ...[
                      _CableTvBeneficiariesRow(
                        beneficiaries: state.beneficiaries,
                        isFetchingMore: state.isFetchingMoreBeneficiaries,
                        onLoadMore: () {
                          context.read<CableTvBloc>().add(
                                CableTvBeneficiariesRequested(),
                              );
                        },
                        onTap: (ub) {
                          context.read<CableTvBloc>().add(
                                CableTvBeneficiarySelected(ub),
                              );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Smartcard Number input ──
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: hasSelectedProvider ? 1.0 : 0.35,
                      child: AbsorbPointer(
                        absorbing: !hasSelectedProvider,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Smartcard Number',
                              hint: 'Enter smartcard number',
                              controller: _ensureSmartcardController(state),
                              keyboardType: TextInputType.number,
                              enabled: hasSelectedProvider,
                              onChanged: (value) {
                                final normalizedValue = value.trim();

                                context.read<CableTvBloc>().add(
                                      CableTvSmartcardChanged(normalizedValue),
                                    );

                                if (normalizedValue.length >= 10) {
                                  final isAlreadyVerified = state.customer != null;
                                  final isCurrentInputSameAsState = state.smartcardNumber == normalizedValue;

                                  if (!isAlreadyVerified || !isCurrentInputSameAsState) {
                                    context.read<CableTvBloc>().add(
                                          CableTvVerifyRequested(),
                                        );
                                  }
                                }
                              },
                              textInputAction: TextInputAction.next,
                            ),

                            // ── Verification Feedback Area ──
                            if (hasValidSmartcardLength) ...[
                              const SizedBox(height: 8),
                              if (isLoadingVerification) ...[
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Verifying account details...',
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ] else if (isVerified) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDFAF1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFB7EBC4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.customer!.name,
                                          style: TextStyle(
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (state.verifyError != null && state.verifyError!.isNotEmpty) ...[
                                Text(
                                  state.verifyError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],

                            // ── Package list and amount, displayed ONLY after successful verification ──
                            if (isVerified) ...[
                              const SizedBox(height: 28),
                              const Text('Select Package', style: AppTextStyles.headingSmall),
                              const SizedBox(height: 12),
                              Container(
                                height: 280,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE8EBF5)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: state.isProductsLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.all(12),
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: state.packages.length,
                                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                                          itemBuilder: (context, i) => _PackageCard(
                                            package: state.packages[i],
                                            isSelected: i == state.selectedPackageIndex,
                                            onTap: () => context.read<CableTvBloc>().add(CableTvPackageSelected(i)),
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 28),
                              AmountEntryCard(
                                controller: _ensureAmountController(state),
                                availableBalanceKobo: state.availableBalanceKobo,
                                enabled: false,
                              ),

                              const SizedBox(height: 28),
                              PrimaryButton(
                                label: state.amountKobo > 0
                                    ? 'Pay ${state.formattedAmount}'
                                    : 'Pay',
                                isEnabled: isFormValid,
                                onPressed: () => _navigateToReview(context),
                              ),
                            ],
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

  Widget _buildProviderSection(BuildContext context, CableTvState state) {
    const providerLabel = 'Select provider';
    final List<ServiceProviderModel> providers = state.providers;

    if (state.isProvidersLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            providerLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ShimmerWidget.buildShimmerRow(
              itemCount: 3,
              itemWidth: 160,
              itemHeight: 68,
              spacing: 12,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      );
    }

    if (state.errorMessage.isNotEmpty && providers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            providerLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
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
              state.errorMessage,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.read<CableTvBloc>().add(CableTvInitRequested());
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          providerLabel,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final provider = providers[index];
              final isSelected = provider.name == state.selectedProvider;

              return GestureDetector(
                onTap: () {
                  context.read<CableTvBloc>().add(
                        CableTvProviderSelected(
                          provider.name,
                          providerId: provider.id,
                        ),
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 160,
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border.withValues(alpha: 0.5),
                      width: isSelected ? 2.0 : 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.grey.shade100,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: provider.logo != null && provider.logo!.isNotEmpty
                              ? Image.network(
                                  provider.logo!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholderLetter(provider.name),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primary.withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : _buildPlaceholderLetter(provider.name),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
        fontSize: 16,
      ),
    );
  }
  void _navigateToReview(BuildContext context) {
    final bloc = context.read<CableTvBloc>();
    final state = bloc.state;
    final repo = context.read<ServiceRepository>();

    final args = ServiceReviewArgs(
      title: 'Cable TV',
      amountKobo: state.amountKobo,
      recipient: state.smartcardNumber.trim(),
      providerName: state.selectedProvider,
      icon: Icons.tv_rounded,
      summaryDetails: [
        ServiceReviewDetail(
          label: 'Provider',
          value: state.selectedProvider,
        ),
        ServiceReviewDetail(
          label: 'Smartcard Number',
          value: state.smartcardNumber.trim(),
        ),
        if (state.customer != null)
          ServiceReviewDetail(
            label: 'Customer Name',
            value: state.customer!.name,
          ),
        if (state.selectedPackage != null)
          ServiceReviewDetail(
            label: 'Package',
            value: state.selectedPackage!.name,
          ),
        ServiceReviewDetail(
          label: 'Amount',
          value: state.formattedAmount,
        ),
      ],
      onPay: (pin, paymentSource) async {
        final token = await repo.verifyPin(pin);
        final providerId = state.selectedProviderId.isNotEmpty
            ? state.selectedProviderId
            : state.selectedProvider;
        return repo.subscribeCableTv(
          provider: providerId,
          smartcardNumber: state.smartcardNumber.replaceAll(RegExp(r'\s+'), ''),
          amountKobo: state.amountKobo,
          pin: pin,
          bundleCode: state.selectedPackage!.bundleCode,
          challengeToken: token,
          paymentSource: paymentSource,
        );
      },
      onCancel: () => bloc.add(CableTvSuccessDismissed()),
    );

    context.push('/service/review', extra: args);
  }
}

class _CableTvBeneficiariesRow extends StatefulWidget {
  final List<CableTvBeneficiary> beneficiaries;
  final ValueChanged<CableTvBeneficiary> onTap;
  final VoidCallback onLoadMore;
  final bool isFetchingMore;

  const _CableTvBeneficiariesRow({
    required this.beneficiaries,
    required this.onTap,
    required this.onLoadMore,
    required this.isFetchingMore,
  });

  @override
  State<_CableTvBeneficiariesRow> createState() => _CableTvBeneficiariesRowState();
}

class _CableTvBeneficiariesRowState extends State<_CableTvBeneficiariesRow> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _CableTvBeneficiariesRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFetchingMore && !widget.isFetchingMore) {
      _isLoadingTriggered = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && !widget.isFetchingMore && !_isLoadingTriggered) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 100) {
        setState(() {
          _isLoadingTriggered = true;
        });
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Smartcards',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.beneficiaries.length + (widget.isFetchingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (i == widget.beneficiaries.length) {
                return const SizedBox(
                  width: 68,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              return _CableTvBeneficiaryChip(
                beneficiary: widget.beneficiaries[i],
                onTap: () => widget.onTap(widget.beneficiaries[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CableTvBeneficiaryChip extends StatelessWidget {
  final CableTvBeneficiary beneficiary;
  final VoidCallback onTap;

  const _CableTvBeneficiaryChip({
    required this.beneficiary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = beneficiary.customerName.trim();
    final displayName = name.isNotEmpty
        ? (name.split(' ').first)
        : 'User';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.tv_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              displayName,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Package Card ─────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final ServiceProductModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8EBF5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _RadioDot(isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        package.name,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.priceLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
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

// ── Radio dot helper ─────────────────────────────────────────────────────────

class _RadioDot extends StatelessWidget {
  final bool isSelected;

  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
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
