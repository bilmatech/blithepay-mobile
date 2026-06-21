import 'package:flutter/material.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:blithepay/features/vas/core/utils/balance_helper.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/top_off_grid.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/core/presentation/views/service_review_view.dart';
import 'package:blithepay/features/vas/airtime/presentation/widgets/amount_entry_card.dart' show AmountEntryCard;
import 'package:blithepay/features/vas/core/data/models/utility_beneficiary_model.dart';


class ElectricityPurchaseView extends StatelessWidget {
  final ServiceEntity? service;

  const ElectricityPurchaseView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final initialBalance = getWalletBalanceKobo(context);

    return BlocProvider(
      create: (context) => ServiceBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: service?.id,
        config: ServiceConfig(
          title: 'Electricity',
          recipientLabel: 'Meter Number',
          recipientHint: 'Enter meter number',
          providerLabel: 'Select distributor',
          providerOptions: const ['PHCN', 'EKEDC', 'AEDC', 'IKEDC'],
          plans: const [
            ServicePlan(
              title: 'Prepaid',
              bundleCode: '',
              description: 'Load tokens instantly',
              amountKobo: 300000,
              priceLabel: '₦3,000',
            ),
            ServicePlan(
              title: 'Postpaid',
              description: 'Pay your monthly bill',
              amountKobo: 850000,
              bundleCode: '',
              priceLabel: '₦8,500',
            ),
          ],
          presetAmounts: const [300000, 500000, 850000, 1000000, 1500000, 2000000],
          availableBalanceKobo: initialBalance,
        ),
      ),
      child: const _ElectricityView(),
    );
  }
}

class _ElectricityView extends StatefulWidget {
  const _ElectricityView();

  @override
  State<_ElectricityView> createState() => _ElectricityViewState();
}

class _ElectricityViewState extends State<_ElectricityView> {
  TextEditingController? _meterController;
  TextEditingController? _amountController;

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(ServiceUtilityBeneficiariesRequested());
  }

  @override
  void dispose() {
    _meterController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

  TextEditingController _ensureMeterController(ServiceState state) {
    if (_meterController != null && _meterController!.text != state.recipient) {
      _meterController!.text = state.recipient;
      _meterController!.selection = TextSelection.collapsed(offset: state.recipient.length);
    }
    return _meterController ??= TextEditingController(text: state.recipient);
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

  List<int> _getDynamicPresets(int minVendKobo) {
    final List<int> list = [minVendKobo];
    final standardAmounts = [
      100000,  // 1k
      200000,  // 2k
      300000,  // 3k
      500000,  // 5k
      800000,  // 8k
      1000000, // 10k
      1500000, // 15k
      2000000, // 20k
    ];
    
    for (final amt in standardAmounts) {
      if (amt > minVendKobo) {
        list.add(amt);
      }
      if (list.length >= 6) {
        break;
      }
    }
    
    while (list.length < 6) {
      final last = list.last;
      list.add(last + 500000);
    }
    
    return list;
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
                  context.read<ServiceBloc>().add(ServiceBalanceUpdated(balanceKobo));
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
                    context.read<ServiceBloc>().add(ServiceBalanceUpdated(balanceKobo));
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              final hasSelectedProvider = state.selectedProvider.isNotEmpty;
              final bool hasValidMeterLength = state.recipient.trim().length >= 10;
              final bool isLoadingVerification = state.isProcessing && hasValidMeterLength;
              final bool isVerified = state.verifiedCustomerName != null;

              final minVendKobo = state.minVendAmountKobo ?? 0;
              final bool isAmountValid = state.amountKobo >= minVendKobo && state.amountKobo > 0;
              final bool isFormValid = isVerified && isAmountValid && hasSelectedProvider && !state.isProcessing;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Electricity',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Distributor circular section ──
                    _buildDistributorSection(context, state),

                    const SizedBox(height: 28),

                    // ── Utility Beneficiaries Section ──
                    if (state.utilityBeneficiaries.isNotEmpty) ...[
                      _UtilityBeneficiariesRow(
                        beneficiaries: state.utilityBeneficiaries,
                        isFetchingMore: state.isFetchingMoreUtilityBeneficiaries,
                        onLoadMore: () {
                          context.read<ServiceBloc>().add(
                                ServiceUtilityBeneficiariesRequested(),
                              );
                        },
                        onTap: (ub) {
                          context.read<ServiceBloc>().add(
                                ServiceUtilityBeneficiarySelected(ub),
                              );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Everything below only visible after distributor selection ──
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: hasSelectedProvider ? 1.0 : 0.35,
                      child: AbsorbPointer(
                        absorbing: !hasSelectedProvider,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Meter Number Input ──
                            AppTextField(
                              label: 'Meter Number',
                              hint: 'Enter meter number',
                              controller: _ensureMeterController(state),
                              keyboardType: TextInputType.number,
                              enabled: hasSelectedProvider,
                              onChanged: (value) {
                                final normalizedValue = value.trim();

                                context.read<ServiceBloc>().add(
                                  ServiceRecipientChanged(normalizedValue),
                                );

                                if (normalizedValue.length >= 11) {
                                  final isAlreadyVerified = state.verifiedCustomerName != null;
                                  final isCurrentInputSameAsState = state.recipient == normalizedValue;

                                  if (!isAlreadyVerified || !isCurrentInputSameAsState) {
                                    context.read<ServiceBloc>().add(
                                      ServiceVerifyMeterRequested(normalizedValue),
                                    );
                                  }
                                }
                              },
                              textInputAction: TextInputAction.next,
                            ),

                            // ── Verification Feedback Area ──
                            if (hasValidMeterLength) ...[
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
                                          '${state.verifiedCustomerName}',
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
                              ] else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                                Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],

                            // ── Amount selection and grid, displayed ONLY after successful verification ──
                            if (isVerified) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'Meter Type',
                                style: AppTextStyles.headingSmall,
                              ),
                              const SizedBox(height: 12),
                              _MeterTypeTabs(
                                selectedIndex: state.selectedPlanIndex ?? 0,
                                labels: state.config.plans.map((p) => p.title).toList(),
                                onSelected: (index) {
                                  context.read<ServiceBloc>().add(ServicePlanSelected(index));
                                },
                              ),
                              const SizedBox(height: 28),
                              const Text('Top Off', style: AppTextStyles.headingSmall),
                              const SizedBox(height: 12),
                              TopOffGrid(
                                selectedAmountKobo: state.amountKobo,
                                amounts: state.minVendAmountKobo != null && state.minVendAmountKobo! > 0
                                    ? _getDynamicPresets(state.minVendAmountKobo!)
                                    : state.config.presetAmounts,
                                onAmountSelected: (value) {
                                  _ensureAmountController(state).text = _formatAmount(value);
                                  context.read<ServiceBloc>().add(ServiceAmountSelected(value));
                                },
                              ),
                              const SizedBox(height: 20),
                              AmountEntryCard(
                                controller: _ensureAmountController(state),
                                availableBalanceKobo: state.availableBalanceKobo,
                                onAmountChanged: (value) {
                                  context.read<ServiceBloc>().add(ServiceAmountSelected(value));
                                },
                              ),

                              // ── Minimum Vend Warning ──
                              if (state.amountKobo > 0 && state.amountKobo < minVendKobo) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Amount must be at least ₦${(minVendKobo / 100).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

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

  Widget _buildDistributorSection(BuildContext context, ServiceState state) {
    final providerLabel = state.config.providerLabel;

    final List<ServiceProviderModel> providers = state.providers.isNotEmpty
        ? state.providers
        : state.config.providerOptions
            .map((name) => ServiceProviderModel(id: name, name: name))
            .toList();

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

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty && !state.isProcessing && !state.isProvidersLoading && state.providers.isEmpty) {
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
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                final serviceId = state.selectedProviderId;
                if (serviceId != null && serviceId.isNotEmpty) {
                  context.read<ServiceBloc>().add(
                    ServiceProvidersRequested(serviceId),
                  );
                }
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
        Text(
          providerLabel,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
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
                  context.read<ServiceBloc>().add(
                        ServiceProviderSelected(
                          provider.name,
                          providerId: state.providers.isNotEmpty
                              ? provider.id
                              : null,
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
    final bloc = context.read<ServiceBloc>();
    final currentState = bloc.state;
    final repo = context.read<ServiceRepository>();

    final meterType = currentState.config.plans.isNotEmpty &&
            (currentState.selectedPlanIndex ?? 0) <
                currentState.config.plans.length
        ? currentState.config.plans[currentState.selectedPlanIndex ?? 0].title
        : 'Prepaid';

    final formattedAmount =
        '₦${(currentState.amountKobo / 100).toStringAsFixed(2)}';

    final args = ServiceReviewArgs(
      title: 'Electricity',
      amountKobo: currentState.amountKobo,
      recipient: currentState.recipient.trim(),
      providerName: currentState.selectedProvider,
      icon: Icons.bolt_rounded,
      summaryDetails: [
        ServiceReviewDetail(
          label: 'Distributor',
          value: currentState.selectedProvider,
        ),
        ServiceReviewDetail(
          label: 'Meter Number',
          value: currentState.recipient.trim(),
        ),
        if (currentState.verifiedCustomerName != null)
          ServiceReviewDetail(
            label: 'Customer',
            value: currentState.verifiedCustomerName!,
          ),
        ServiceReviewDetail(label: 'Meter Type', value: meterType),
        ServiceReviewDetail(label: 'Amount', value: formattedAmount),
      ],
      onPay: (pin) async {
        final token = await repo.verifyPin(pin);
        final providerId = currentState.selectedProviderId ?? currentState.selectedProvider;
        return repo.purchaseUtility(
          serviceId: providerId.isNotEmpty ? providerId : (bloc.currentServiceId ?? ''),
          meterNumber:
              currentState.recipient.replaceAll(RegExp(r'\s+'), ''),
          meterType: currentState.meterType,
          amountKobo: currentState.amountKobo,
          challengeToken: token,
        );
      },
      onCancel: () => bloc.add(ServiceResetRequested()),
    );

    context.push('/service/review', extra: args);
  }
}

class _MeterTypeTabs extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const _MeterTypeTabs({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final selected = index == selectedIndex;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFF61708A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UtilityBeneficiariesRow extends StatefulWidget {
  final List<UtilityBeneficiary> beneficiaries;
  final ValueChanged<UtilityBeneficiary> onTap;
  final VoidCallback onLoadMore;
  final bool isFetchingMore;

  const _UtilityBeneficiariesRow({
    required this.beneficiaries,
    required this.onTap,
    required this.onLoadMore,
    required this.isFetchingMore,
  });

  @override
  State<_UtilityBeneficiariesRow> createState() => _UtilityBeneficiariesRowState();
}

class _UtilityBeneficiariesRowState extends State<_UtilityBeneficiariesRow> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _UtilityBeneficiariesRow oldWidget) {
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
          'Previous Meter Accounts',
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
              return _UtilityBeneficiaryChip(
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

class _UtilityBeneficiaryChip extends StatelessWidget {
  final UtilityBeneficiary beneficiary;
  final VoidCallback onTap;

  const _UtilityBeneficiaryChip({
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
                  Icons.bolt_rounded,
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
