import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
// ignore: unused_import
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/service_bloc/service_bloc.dart';
import '../shared/reusable_service_view.dart';
import '../shared/service_overlays.dart';

class CableTvServiceView extends StatelessWidget {
  const CableTvServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceBloc(
        config: const ServiceConfig(
          title: 'Cable/TV',
          recipientLabel: 'Smartcard Number',
          recipientHint: 'Enter smartcard number',
          providerLabel: 'Select provider',
          providerOptions: ['DStv', 'GOtv', 'Startimes'],
          plans: [
            ServicePlan(
              title: 'Basic Package',
              description: 'Good for local channels',
              amountKobo: 350000,
              priceLabel: '₦3,500',
            ),
            ServicePlan(
              title: 'Classic Package',
              description: 'More channels and movies',
              amountKobo: 550000,
              priceLabel: '₦5,500',
            ),
            ServicePlan(
              title: 'Premium Package',
              description: 'All channels included',
              amountKobo: 950000,
              priceLabel: '₦9,500',
            ),
          ],
          presetAmounts: [350000, 550000, 950000, 1200000, 1500000, 2000000],
          availableBalanceKobo: 9455272,
        ),
      ),
      child: AppScaffold(
        appBar: AppBar(
          leading: const BackArrowButtonIcon(),
          title: const Text('Services'),
          centerTitle: true,
        ),
        body: const Center(child: Text('TV Subscription')),
      ),

      // child: const _CableTvServiceScreen(),
    );
  }
}

class _CableTvServiceScreen extends StatefulWidget {
  const _CableTvServiceScreen();

  @override
  State<_CableTvServiceScreen> createState() => _CableTvServiceScreenState();
}

class _CableTvServiceScreenState extends State<_CableTvServiceScreen> {
  TextEditingController? _smartcardController;
  TextEditingController? _amountController;

  @override
  void dispose() {
    _smartcardController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceView<ServiceBloc, ServiceState>(
      title: 'Cable/TV',
      formBuilder: (context, state) => CableTvServiceForm(
        state: state,
        smartcardController: _ensureSmartcardController(state),
        amountController: _ensureAmountController(state),
      ),
      overlayBuilder: (context, state) => ServiceStageOverlay(state: state),
    );
  }

  TextEditingController _ensureSmartcardController(ServiceState state) {
    return _smartcardController ??= TextEditingController(
      text: state.recipient,
    );
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

class CableTvServiceForm extends StatefulWidget {
  final ServiceState state;
  final TextEditingController smartcardController;
  final TextEditingController amountController;

  const CableTvServiceForm({
    super.key,
    required this.state,
    required this.smartcardController,
    required this.amountController,
  });

  @override
  State<CableTvServiceForm> createState() => _CableTvServiceFormState();
}

class _CableTvServiceFormState extends State<CableTvServiceForm> {
  bool _isProviderListVisible = false;

  @override
  void didUpdateWidget(CableTvServiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.recipient != widget.state.recipient) {
      widget.smartcardController.text = widget.state.recipient;
      widget.smartcardController.selection = TextSelection.collapsed(
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
          'Smartcard Number',
          style: TextStyle(
            color: Color(0xFF262832),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: '',
          hint: 'Enter smartcard number',
          controller: widget.smartcardController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 24),
        const Text(
          'Provider',
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
              _isProviderListVisible = !_isProviderListVisible;
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
                  _isProviderListVisible
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_isProviderListVisible) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E7F2)),
            ),
            child: Column(
              children: widget.state.config.providerOptions.map((provider) {
                return InkWell(
                  onTap: () {
                    context.read<ServiceBloc>().add(
                      ServiceProviderSelected(provider),
                    );
                    setState(() {
                      _isProviderListVisible = false;
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
                          provider,
                          style: const TextStyle(
                            color: Color(0xFF061657),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (provider == widget.state.selectedProvider)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 28),
        const Text(
          'Cable Package',
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
              'Continue',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
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
