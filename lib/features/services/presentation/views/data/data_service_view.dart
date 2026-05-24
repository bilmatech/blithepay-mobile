import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/inputs/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:blithepay/core/constants/app_colors.dart';
// ignore: unused_import
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import '../../bloc/service_bloc/service_bloc.dart';
import '../shared/reusable_service_view.dart';
import '../shared/service_overlays.dart';

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
          plans: [
            ServicePlan(
              title: 'Basic Data',
              description: '500MB for 1 day',
              amountKobo: 20000,
              priceLabel: '₦200',
            ),
            ServicePlan(
              title: 'Daily Plan',
              description: '1GB for 1 day',
              amountKobo: 50000,
              priceLabel: '₦500',
            ),
            ServicePlan(
              title: 'Weekly Plan',
              description: '5GB for 7 days',
              amountKobo: 200000,
              priceLabel: '₦2,000',
            ),
            ServicePlan(
              title: 'Monthly Plan',
              description: '15GB for 30 days',
              amountKobo: 500000,
              priceLabel: '₦5,000',
            ),
          ],
          presetAmounts: [5000, 10000, 20000, 50000, 100000, 200000],
          availableBalanceKobo: 9455272,
        ),
      ),
      child: const _DataServiceScreen(),
    );
  }
}

class _DataServiceScreen extends StatefulWidget {
  const _DataServiceScreen();

  @override
  State<_DataServiceScreen> createState() => _DataServiceScreenState();
}

class _DataServiceScreenState extends State<_DataServiceScreen> {
  TextEditingController? _phoneController;
  TextEditingController? _amountController;

  @override
  void dispose() {
    _phoneController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceView<ServiceBloc, ServiceState>(
      title: 'Data',
      formBuilder: (context, state) => DataServiceForm(
        state: state,
        phoneController: _ensurePhoneController(state),
        amountController: _ensureAmountController(state),
      ),
      overlayBuilder: (context, state) => ServiceStageOverlay(state: state),
    );
  }

  TextEditingController _ensurePhoneController(ServiceState state) {
    return _phoneController ??= TextEditingController(text: state.recipient);
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

class DataServiceForm extends StatefulWidget {
  final ServiceState state;
  final TextEditingController phoneController;
  final TextEditingController amountController;

  const DataServiceForm({
    required this.state,
    required this.phoneController,
    required this.amountController,
  });

  @override
  State<DataServiceForm> createState() => _DataServiceFormState();
}

class _DataServiceFormState extends State<DataServiceForm> {
  bool _isNetworkListVisible = false;

  @override
  void didUpdateWidget(DataServiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.recipient != widget.state.recipient) {
      widget.phoneController.text = widget.state.recipient;
      widget.phoneController.selection = TextSelection.collapsed(
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
        const Text(
          'Recipient Phone',
          style: TextStyle(
            color: Color(0xFF262832),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        PhoneNumberField(
          controller: widget.phoneController,
          isBeneficiaryListVisible: widget.state.isBeneficiaryListVisible,
          onBeneficiariesToggle: () {
            context.read<ServiceBloc>().add(ServiceBeneficiaryListToggled());
          },
          onChanged: (value) {
            context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
          },
        ),

        // AppTextField(
        //   label: '',
        //   hint: 'Enter phone number',
        //   controller: widget.phoneController,
        //   keyboardType: TextInputType.phone,
        //   onChanged: (value) {
        //     context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
        //   },
        //   textInputAction: TextInputAction.next,
        // ),
        // const SizedBox(height: 24),
        // const Text(
        //   'Network',
        //   style: TextStyle(
        //     color: Color(0xFF262832),
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        // const SizedBox(height: 12),
        // InkWell(
        //   borderRadius: BorderRadius.circular(14),
        //   onTap: () {
        //     setState(() {
        //       _isNetworkListVisible = !_isNetworkListVisible;
        //     });
        //   },
        //   child: Container(
        //     width: double.infinity,
        //     height: 60,
        //     padding: const EdgeInsets.symmetric(horizontal: 16),
        //     decoration: BoxDecoration(
        //       color: const Color(0xFFF9FAFF),
        //       borderRadius: BorderRadius.circular(14),
        //       border: Border.all(color: const Color(0xFFE3E7F2)),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           widget.state.selectedProvider,
        //           style: const TextStyle(
        //             color: Color(0xFF061657),
        //             fontSize: 16,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //         Icon(
        //           _isNetworkListVisible
        //               ? Icons.keyboard_arrow_up_rounded
        //               : Icons.keyboard_arrow_down_rounded,
        //           size: 24,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // if (_isNetworkListVisible) ...[
        //   const SizedBox(height: 8),
        //   Container(
        //     decoration: BoxDecoration(
        //       color: AppColors.white,
        //       borderRadius: BorderRadius.circular(14),
        //       border: Border.all(color: const Color(0xFFE3E7F2)),
        //     ),
        //     child: Column(
        //       children: widget.state.config.providerOptions.map((provider) {
        //         return InkWell(
        //           onTap: () {
        //             context.read<ServiceBloc>().add(
        //               ServiceProviderSelected(provider),
        //             );
        //             setState(() {
        //               _isNetworkListVisible = false;
        //             });
        //           },
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 16,
        //               vertical: 14,
        //             ),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Text(
        //                   provider,
        //                   style: const TextStyle(
        //                     color: Color(0xFF061657),
        //                     fontSize: 16,
        //                     fontWeight: FontWeight.w500,
        //                   ),
        //                 ),
        //                 if (provider == widget.state.selectedProvider)
        //                   const Icon(
        //                     Icons.check_circle,
        //                     color: AppColors.primary,
        //                     size: 20,
        //                   ),
        //               ],
        //             ),
        //           ),
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ],
        const SizedBox(height: 28),
        const Text(
          'Data Plan',
          style: TextStyle(
            color: Color(0xFF262832),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.state.config.plans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = widget.state.config.plans[index];
            final isSelected = index == (widget.state.selectedPlanIndex ?? 0);

            return InkWell(
              onTap: () {
                context.read<ServiceBloc>().add(ServicePlanSelected(index));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE3E7F2),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: const TextStyle(
                              color: Color(0xFF061657),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: const TextStyle(
                              color: Color(0xFF4B4B52),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      plan.priceLabel,
                      style: const TextStyle(
                        color: Color(0xFF061657),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          onPressed: () {
            context.read<ServiceBloc>().add(ServiceReviewRequested());
          },
          label: 'Pay',
        ),
      ],
    );
  }

  String _formatAmount(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }
}
