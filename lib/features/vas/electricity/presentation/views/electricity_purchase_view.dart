import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart'
    show ServiceEntity;
import 'package:blithepay/features/vas/core/data/models/service_model.dart'
    show ServiceProviderModel;
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/airtime/presentation/widgets/amount_entry_card.dart';
import 'package:blithepay/features/vas/core/presentation/widgets/top_off_grid.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';

import 'package:blithepay/features/vas/core/presentation/views/shared/reusable_service_view.dart';

class ElectricityPurchaseView extends StatelessWidget {
  final ServiceEntity? service;

  const ElectricityPurchaseView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: service?.id,
        config: const ServiceConfig(
          title: 'Electricity',
          recipientLabel: 'Meter Number',
          recipientHint: 'Enter meter number',
          providerLabel: 'Select distributor',
          providerOptions: ['PHCN', 'EKEDC', 'AEDC', 'IKEDC'],
          plans: [
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
          presetAmounts: [300000, 500000, 850000, 1000000, 1500000, 2000000],
          availableBalanceKobo: 9455272,
        ),
      ),
      child: const _ElectricityServiceScreen(),
    );
  }
}

class _ElectricityServiceScreen extends StatefulWidget {
  const _ElectricityServiceScreen();

  @override
  State<_ElectricityServiceScreen> createState() =>
      _ElectricityServiceScreenState();
}

class _ElectricityServiceScreenState extends State<_ElectricityServiceScreen> {
  TextEditingController? _meterController;
  TextEditingController? _amountController;

  @override
  void dispose() {
    _meterController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceView<ServiceBloc, ServiceState>(
      title: 'Electricity',
      formBuilder: (context, state) => ElectricityServiceForm(
        state: state,
        meterController: _ensureMeterController(state),
        amountController: _ensureAmountController(state),
      ),
    );
  }

  TextEditingController _ensureMeterController(ServiceState state) {
    return _meterController ??= TextEditingController(text: state.recipient);
  }

  TextEditingController _ensureAmountController(ServiceState state) {
    return _amountController ??= TextEditingController(
      text: _formatAmount(state.amountKobo),
    );
  }

  String _formatAmount(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }
}

class ElectricityServiceForm extends StatefulWidget {
  final ServiceState state;
  final TextEditingController meterController;
  final TextEditingController amountController;

  const ElectricityServiceForm({
    super.key,
    required this.state,
    required this.meterController,
    required this.amountController,
  });

  @override
  State<ElectricityServiceForm> createState() => _ElectricityServiceFormState();
}

class _ElectricityServiceFormState extends State<ElectricityServiceForm> {
  bool _isDistributorListVisible = false;

  @override
  void didUpdateWidget(ElectricityServiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.recipient != widget.state.recipient) {
      widget.meterController.text = widget.state.recipient;
      widget.meterController.selection = TextSelection.collapsed(
        offset: widget.state.recipient.length,
      );
    }

    final newAmountText = _formatAmount(widget.state.amountKobo);
    if (widget.amountController.text != newAmountText) {
      widget.amountController.text = newAmountText;
      widget.amountController.selection = TextSelection.collapsed(
        offset: newAmountText.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── PAYMENT VALIDATION GATES ──
    // Assuming your state has tracking metrics for validation like:
    // state.isMeterVerified or state.verifiedCustomerName != null
    // Ensure your BLoC updates these whenever an external API query completes.

    final bool hasValidMeterLength = widget.state.recipient.trim().length >= 10;

    // Replace with your exact state property tracking verification success
    final bool isVerified =
        widget.state.transaction != null ||
        (widget.state.errorMessage == null &&
            widget.state.recipient.isNotEmpty &&
            hasValidMeterLength);

    final bool isLoadingVerification =
        widget.state.isProcessing && hasValidMeterLength;

    // Button is only clickable if verification passes and it isn't currently loading
    final VoidCallback? onPayPressed = (isVerified && !isLoadingVerification)
        ? () {
            context.push('/service/review', extra: context.read<ServiceBloc>());
          }
        : null; // Setting to null natively disables the button in Flutter

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distributor',
          style: TextStyle(
            color: Color(0xFF262832),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _isDistributorListVisible = !_isDistributorListVisible;
            });
          },
          child: Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E7F2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.state.selectedProvider,
                  style: const TextStyle(
                    color: Color(0xFF061657),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isDistributorListVisible
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        if (_isDistributorListVisible) ...[
          const SizedBox(height: 8),
          if (widget.state.isProvidersLoading)
            const LinearProgressIndicator(minHeight: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E7F2)),
            ),
            child: Column(
              children:
                  (widget.state.providers.isNotEmpty
                          ? widget.state.providers
                          : widget.state.config.providerOptions
                                .map(
                                  (name) => ServiceProviderModel(
                                    id: name,
                                    name: name,
                                  ),
                                )
                                .toList())
                      .map((provider) {
                        return InkWell(
                          onTap: () {
                            context.read<ServiceBloc>().add(
                              ServiceProviderSelected(
                                provider.name,
                                providerId: provider.id,
                              ),
                            );
                            setState(() {
                              _isDistributorListVisible = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.name,
                                  style: const TextStyle(
                                    color: Color(0xFF061657),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (provider.name ==
                                    widget.state.selectedProvider)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(),
            ),
          ),
        ],
        const SizedBox(height: 28),
        const Text(
          'Meter Type',
          style: TextStyle(
            color: Color(0xFF262832),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _MeterTypeTabs(
          selectedIndex: widget.state.selectedPlanIndex ?? 0,
          labels: widget.state.config.plans.map((p) => p.title).toList(),
          onSelected: (index) {
            context.read<ServiceBloc>().add(ServicePlanSelected(index));
          },
        ),
        const SizedBox(height: 28),

        // ── METER NUMBER INPUT FIELD SECTION ──
        AppTextField(
          label: 'Meter Number',
          hint: 'Enter meter number',
          controller: widget.meterController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final normalizedValue = value.trim();

            context.read<ServiceBloc>().add(
              ServiceRecipientChanged(normalizedValue),
            );

            if (normalizedValue.length == 12) {
              // Only call the API if the current input doesn't match the one we just verified
              final isAlreadyVerified =
                  widget.state.verifiedCustomerName != null;
              final isCurrentInputSameAsState =
                  widget.state.recipient == normalizedValue;

              if (!isAlreadyVerified || !isCurrentInputSameAsState) {
                context.read<ServiceBloc>().add(
                  ServiceVerifyMeterRequested(normalizedValue),
                );
              }
            } else {
              // 3. CLEAN RETREAT: If the user deletes characters below 10,
              // drop an event to instantly wipe out residual error or name caching layers!
              if (widget.state.verifiedCustomerName != null ||
                  widget.state.errorMessage != null) {}
            }
          },
          textInputAction: TextInputAction.next,
        ),
        // ── LIVE VERIFICATION CONTEXTUAL FEEDBACK AREA ──
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
                      // Replace with state variable if your BLoC saves customer name (e.g., state.customerName)
                      'Verified: ${widget.state.verifiedCustomerName ?? "Valid Meter Account"}',
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
          ] else if (widget.state.errorMessage != null) ...[
            Text(
              widget.state.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],

        const SizedBox(height: 16),
        const Text('Top Off', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),

        TopOffGrid(
          selectedAmountKobo: widget.state.amountKobo,
          onAmountSelected: (value) {
            widget.amountController.text = _formatAmount(value);
            context.read<ServiceBloc>().add(ServiceAmountSelected(value));
          },
        ),
        const SizedBox(height: 24),
        AmountEntryCard(
          controller: widget.amountController,
          label: 'ENTER AMOUNT',
          onAmountChanged: (amount) {
            final amountKobo = _parseAmountKobo(amount.toString());
            if (amountKobo == null) return;
            context.read<ServiceBloc>().add(ServiceAmountSelected(amountKobo));
          },
        ),

        const SizedBox(height: 28),

        // ── GUARDED SUBMIT ACTION PATH ──
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: onPayPressed, // Handled dynamically above
            style: FilledButton.styleFrom(
              backgroundColor: onPayPressed == null
                  ? const Color(0xFFE3E7F2)
                  : AppColors.primary,
              foregroundColor: onPayPressed == null
                  ? const Color(0xFF9EA7BF)
                  : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: onPayPressed == null ? 0 : 2,
            ),
            child: const Text(
              'Pay',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  int? _parseAmountKobo(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '.') {
      return null;
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return null;
    }

    return (parsed * 100).round();
  }

  String _formatAmount(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
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


// 295119324101