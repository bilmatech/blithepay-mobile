import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart'
    show ServiceEntity;
import 'package:blithepay/features/services/data/models/service_model.dart'
    show ServiceProviderModel;
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
import 'package:blithepay/features/services/presentation/views/airtime/widgets/amount_entry_card.dart';
import 'package:blithepay/features/services/presentation/widgets/top_off_grid.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/service_bloc/service_bloc.dart';
import '../../shared/reusable_service_view.dart';
import '../../shared/service_overlays.dart';

class ElectricityServiceView extends StatelessWidget {
  final ServiceEntity? service;

  const ElectricityServiceView({super.key, this.service});

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
              bundleCode: '22',
              description: 'Load tokens instantly',
              amountKobo: 300000,
              priceLabel: '₦3,000',
            ),
            ServicePlan(
              title: 'Postpaid',
              description: 'Pay your monthly bill',
              amountKobo: 850000,
              bundleCode: '22',

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
      overlayBuilder: (context, state) => ServiceStageOverlay(state: state),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 24),
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

        AppTextField(
          label: 'Meter Number',
          hint: 'Enter meter number',
          controller: widget.meterController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        const Text('Top Off', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),

        // Wrap(
        //   spacing: 12,
        //   runSpacing: 12,
        //   children: widget.state.config.presetAmounts.map((amountKobo) {
        //     final amount = amountKobo ~/ 100;
        //     return SizedBox(
        //       width: 130,
        //       height: 50,
        //       child: OutlinedButton(
        //         onPressed: () {
        //           widget.amountController.text = _formatAmount(amountKobo);
        //           context.read<ServiceBloc>().add(
        //             ServiceAmountSelected(amountKobo),
        //           );
        //         },
        //         style: OutlinedButton.styleFrom(
        //           foregroundColor: AppColors.primary,
        //           side: const BorderSide(color: Color(0xFFE3E7F2)),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //         ),
        //         child: Text(
        //           '₦${_formatAmountChip(amount)}',
        //           style: const TextStyle(
        //             fontSize: 14,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ),
        //     );
        //   }).toList(),
        // ),
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

        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFF9FAFF),
        //     borderRadius: BorderRadius.circular(14),
        //     border: Border.all(color: const Color(0xFFE3E7F2)),
        //   ),
        //   child: Row(
        //     children: [
        //       const Text(
        //         '₦',
        //         style: TextStyle(
        //           color: Color(0xFF061657),
        //           fontSize: 20,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: TextField(
        //           controller: widget.amountController,
        //           onChanged: (value) {
        //             final amountKobo = _parseAmountKobo(value);
        //             if (amountKobo == null) return;
        //             context.read<ServiceBloc>().add(
        //               ServiceAmountSelected(amountKobo),
        //             );
        //           },
        //           keyboardType: const TextInputType.numberWithOptions(
        //             decimal: true,
        //           ),
        //           inputFormatters: [
        //             FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        //           ],
        //           style: const TextStyle(
        //             color: Color(0xFF061657),
        //             fontSize: 18,
        //             fontWeight: FontWeight.w600,
        //           ),
        //           decoration: const InputDecoration(
        //             border: InputBorder.none,
        //             hintText: '0.00',
        //             isDense: true,
        //             contentPadding: EdgeInsets.zero,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 16),
        // Text(
        //   selectedPlan.description,
        //   style: const TextStyle(
        //     color: Color(0xFF4B4B52),
        //     fontSize: 15,
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () {
              context.read<ServiceBloc>().add(ServiceReviewRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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

  String _formatAmountChip(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[index]);
    }

    return buffer.toString();
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
