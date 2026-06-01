import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/services/data/models/beneficiary_model.dart';
import 'package:blithepay/features/services/presentation/views/shared/reusable_service_view.dart';
import 'package:blithepay/features/services/presentation/views/shared/service_overlays.dart';
import 'package:blithepay/features/services/presentation/widgets/service_phone_section.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

// ── Plans dataset ─────────────────────────────────────────────────────────────

const _plans = [
  // Daily
  ServicePlan(title: '300MB', description: 'Valid for 1 day', amountKobo: 10000, priceLabel: '₦100', category: ServicePlanCategory.daily),
  ServicePlan(title: '1GB', description: 'Valid for 1 day', amountKobo: 35000, priceLabel: '₦350', category: ServicePlanCategory.daily),
  ServicePlan(title: '2GB', description: 'Valid for 1 day', amountKobo: 50000, priceLabel: '₦500', category: ServicePlanCategory.daily),
  ServicePlan(title: '3GB', description: 'Valid for 1 day', amountKobo: 70000, priceLabel: '₦700', category: ServicePlanCategory.daily),
  ServicePlan(title: '5GB', description: 'Valid for 1 day', amountKobo: 100000, priceLabel: '₦1,000', category: ServicePlanCategory.daily),
  // Weekly
  ServicePlan(title: '2GB', description: 'Valid for 7 days', amountKobo: 100000, priceLabel: '₦1,000', category: ServicePlanCategory.weekly),
  ServicePlan(title: '5GB', description: 'Valid for 7 days', amountKobo: 200000, priceLabel: '₦2,000', category: ServicePlanCategory.weekly),
  ServicePlan(title: '10GB', description: 'Valid for 7 days', amountKobo: 350000, priceLabel: '₦3,500', category: ServicePlanCategory.weekly),
  ServicePlan(title: '20GB', description: 'Valid for 7 days', amountKobo: 500000, priceLabel: '₦5,000', category: ServicePlanCategory.weekly),
  // Monthly
  ServicePlan(title: '5GB', description: 'Valid for 30 days', amountKobo: 200000, priceLabel: '₦2,000', category: ServicePlanCategory.monthly),
  ServicePlan(title: '15GB', description: 'Valid for 30 days', amountKobo: 500000, priceLabel: '₦5,000', category: ServicePlanCategory.monthly),
  ServicePlan(title: '30GB', description: 'Valid for 30 days', amountKobo: 800000, priceLabel: '₦8,000', category: ServicePlanCategory.monthly),
  ServicePlan(title: '50GB', description: 'Valid for 30 days', amountKobo: 1200000, priceLabel: '₦12,000', category: ServicePlanCategory.monthly),
  ServicePlan(title: '100GB', description: 'Valid for 30 days', amountKobo: 2000000, priceLabel: '₦20,000', category: ServicePlanCategory.monthly),
  // Yearly
  ServicePlan(title: '120GB', description: 'Valid for 365 days', amountKobo: 5000000, priceLabel: '₦50,000', category: ServicePlanCategory.yearly),
  ServicePlan(title: '500GB', description: 'Valid for 365 days', amountKobo: 15000000, priceLabel: '₦150,000', category: ServicePlanCategory.yearly),
  // Unlimited
  ServicePlan(title: 'Unlimited', description: 'Valid for 1 day', amountKobo: 200000, priceLabel: '₦2,000', category: ServicePlanCategory.unlimited),
  ServicePlan(title: 'Unlimited', description: 'Valid for 7 days', amountKobo: 500000, priceLabel: '₦5,000', category: ServicePlanCategory.unlimited),
  ServicePlan(title: 'Unlimited', description: 'Valid for 30 days', amountKobo: 1500000, priceLabel: '₦15,000', category: ServicePlanCategory.unlimited),
];

// ── Root view ─────────────────────────────────────────────────────────────────

class DataServiceView extends StatelessWidget {
  const DataServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceBloc(
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
          Beneficiary(id: '1', phoneNumber: '08031234567', network: ServiceNetwork.mtn),
          Beneficiary(id: '2', phoneNumber: '08115678901', network: ServiceNetwork.glo),
          Beneficiary(id: '3', phoneNumber: '08029876543', network: ServiceNetwork.airtel),
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
  TextEditingController? _phoneController;

  @override
  void dispose() {
    _phoneController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceView<ServiceBloc, ServiceState>(
      title: 'Data',
      formBuilder: (context, state) => DataServiceForm(
        state: state,
        phoneController:
            _phoneController ??= TextEditingController(text: state.phoneNumber),
      ),
      overlayBuilder: (context, state) => ServiceStageOverlay(state: state),
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

  List<(int globalIndex, ServicePlan plan)> get _visiblePlans {
    final allPlans = widget.state.config.plans;
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
                  onTap: () => context
                      .read<ServiceBloc>()
                      .add(ServicePlanSelected(globalIndex)),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Pay ────────────────────────────────────────────────────────────
        PrimaryButton(
          label: widget.state.amountKobo > 0
              ? 'Pay ${widget.state.formattedAmount}'
              : 'Pay',
          onPressed: () {
            context.push(
              '/service/review',
              extra: context.read<ServiceBloc>(),
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
  final ServicePlan plan;
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
                        plan.title,
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
                        plan.description,
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
              child: CircleAvatar(
                radius: 4,
                backgroundColor: AppColors.white,
              ),
            )
          : null,
    );
  }
}
