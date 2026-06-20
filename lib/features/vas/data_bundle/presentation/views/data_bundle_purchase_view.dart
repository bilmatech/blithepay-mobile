import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:flutter/material.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/models/beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/service_phone_section.dart';
import 'package:blithepay/features/vas/core/presentation/views/shared/reusable_service_view.dart';

// ── Plans dataset ─────────────────────────────────────────────────────────────

const _plans = [
  // Daily
  ServicePlan(
    title: '300MB',
    description: 'Valid for 1 day',
    amountKobo: 10000,
    priceLabel: '₦100',
    bundleCode: '',
    category: ServicePlanCategory.daily,
  ),
];

// ── Root view ─────────────────────────────────────────────────────────────────

class DataBundlePurchaseView extends StatelessWidget {
  final ServiceEntity? service;

  const DataBundlePurchaseView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: service?.id,
        config: const ServiceConfig(
          title: 'Data',
          recipientLabel: 'Recipient Phone',
          recipientHint: 'Enter phone number',
          providerLabel: 'Select network',
          providerOptions: ['MTN', 'GLO', 'Airtel', '9mobile'],
          plans: _plans,
          presetAmounts: [],
          availableBalanceKobo: 9455272,
        ),
        // TODO: replace with beneficiaries loaded from local storage / API
        initialBeneficiaries: const [
          Beneficiary(
            id: '1',
            phoneNumber: '08031234567',
            network: ServiceNetwork.mtn,
          ),
          Beneficiary(
            id: '2',
            phoneNumber: '08115678901',
            network: ServiceNetwork.glo,
          ),
          Beneficiary(
            id: '3',
            phoneNumber: '08029876543',
            network: ServiceNetwork.airtel,
          ),
        ],
      ),
      child: const _DataServiceScreen(),
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class _DataServiceScreen extends StatefulWidget {
  const _DataServiceScreen();

  @override
  State<_DataServiceScreen> createState() => _DataServiceScreenState();
}

class _DataServiceScreenState extends State<_DataServiceScreen> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller safely before the first build frame
    final initialState = context.read<ServiceBloc>().state;
    _phoneController = TextEditingController(text: initialState.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant _DataServiceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the controller in sync if the BLoC state changes the phoneNumber externally
    final currentState = context.read<ServiceBloc>().state;
    if (_phoneController.text != currentState.phoneNumber) {
      _phoneController.text = currentState.phoneNumber;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceView<ServiceBloc, ServiceState>(
      title: 'Data',
      formBuilder: (context, state) =>
          DataServiceForm(state: state, phoneController: _phoneController),
    );
  }
}
// ── Form ──────────────────────────────────────────────────────────────────────

class DataServiceForm extends StatefulWidget {
  final ServiceState state;
  final TextEditingController phoneController;

  const DataServiceForm({
    super.key,
    required this.state,
    required this.phoneController,
  });

  @override
  State<DataServiceForm> createState() => _DataServiceFormState();
}

class _DataServiceFormState extends State<DataServiceForm> {
  // null = "All" tab
  ServicePlanCategory? _activeCategory;
  List<(int globalIndex, ServiceProductModel plan)> get _visiblePlans {
    // Read from network products array if available; otherwise use dummy plans safely
    final allPlans = widget.state.products;

    if (allPlans.isEmpty) return const [];

    return [
      for (var i = 0; i < allPlans.length; i++)
        if (_activeCategory == null || allPlans[i].category == _activeCategory)
          (i, allPlans[i]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Recipient ──────────────────────────────────────────────────────
        const Text('Recipient', style: AppTextStyles.headingSmall),
        const SizedBox(height: 10),
        ServicePhoneSection(
          state: widget.state,
          phoneController: widget.phoneController,
        ),

        const SizedBox(height: 28),

        // ── Plan section header ────────────────────────────────────────────
        const Text('Data Plan', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),

        // ── Category tabs ──────────────────────────────────────────────────
        _CategoryTabBar(
          active: _activeCategory,
          onSelected: (cat) => setState(() => _activeCategory = cat),
        ),

        const SizedBox(height: 12),

        // ── Scrollable plan container ──────────────────────────────────────
        Container(
          height: 340,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBF5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              itemCount: _visiblePlans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final (globalIndex, plan) = _visiblePlans[i];
                return _PlanCard(
                  plan: plan,
                  isSelected:
                      globalIndex == (widget.state.selectedPlanIndex ?? 0),
                  onTap: () => context.read<ServiceBloc>().add(
                    ServicePlanSelected(globalIndex),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Pay ────────────────────────────────────────────────────────────
        Builder(
          builder: (context) {
            final products = widget.state.products;
            final selectedIdx = widget.state.selectedPlanIndex;

            final selectedPlan =
                (selectedIdx != null &&
                    selectedIdx >= 0 &&
                    selectedIdx < products.length)
                ? products[selectedIdx]
                : null;

            final buttonLabel = selectedPlan != null
                ? 'Pay ${selectedPlan.priceLabel}'
                : 'Pay';

            return PrimaryButton(
              label: buttonLabel,
              onPressed: selectedPlan != null
                  ? () {
                      context.push(
                        '/service/review',
                        extra: context.read<ServiceBloc>(),
                      );
                    }
                  : () {},
            );
          },
        ),
      ],
    );
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
  final ServiceProductModel plan;
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
