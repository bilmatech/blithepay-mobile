import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ServiceRecipient {
  final String label;
  final String number;
  final String provider;

  const ServiceRecipient({
    required this.label,
    required this.number,
    required this.provider,
  });
}

class ServicePlan {
  final String title;
  final String description;
  final String price;

  const ServicePlan({
    required this.title,
    required this.description,
    required this.price,
  });
}

class ServiceForm extends StatefulWidget {
  final String title;
  final String recipientLabel;
  final String recipientHint;
  final String providerLabel;
  final List<String> providerOptions;
  final bool showPlanSelector;
  final List<ServicePlan>? plans;
  final List<double> presetAmounts;
  final String walletBalance;
  final String actionButtonLabel;
  final String actionSubtitle;
  final IconData serviceIcon;

  const ServiceForm({
    super.key,
    required this.title,
    required this.recipientLabel,
    required this.recipientHint,
    required this.providerLabel,
    required this.providerOptions,
    required this.showPlanSelector,
    this.plans,
    required this.presetAmounts,
    required this.walletBalance,
    required this.actionButtonLabel,
    required this.actionSubtitle,
    required this.serviceIcon,
  });

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedProvider;
  String? _selectedBeneficiary;
  String? _selectedPlan;
  final List<ServiceRecipient> _beneficiaries = [
    const ServiceRecipient(label: 'Me', number: '08012345678', provider: 'MTN'),
    const ServiceRecipient(
      label: 'Wife',
      number: '08087654321',
      provider: 'GLO',
    ),
    const ServiceRecipient(
      label: 'Brother',
      number: '08123456789',
      provider: 'Airtel',
    ),
  ];

  List<ServiceRecipient> get _currentBeneficiaries => _beneficiaries;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(double value) {
    _amountController.text = value.toStringAsFixed(0);
  }

  void _clearBeneficiaries() {
    setState(() {
      _currentBeneficiaries.clear();
      _selectedBeneficiary = null;
    });
  }

  void _removeBeneficiary(int index) {
    setState(() {
      if (index < _currentBeneficiaries.length) {
        _currentBeneficiaries.removeAt(index);
      }
    });
  }

  void _showPaymentFlow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ServicePaymentDetailsBottomSheet(
        title: widget.title,
        recipient: _recipientController.text.isEmpty
            ? 'N/A'
            : _recipientController.text,
        provider: _selectedProvider ?? 'N/A',
        amount: _amountController.text.isEmpty
            ? '₦0.00'
            : '₦${_amountController.text}',
        paymentMethod: 'Wallet on Paystack',
        onPay: () {
          Navigator.pop(context);
          _showPinFlow();
        },
      ),
    );
  }

  void _showPinFlow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ServicePaymentPinBottomSheet(
        onSuccess: () {
          Navigator.pop(context);
          _showSuccessFlow();
        },
      ),
    );
  }

  void _showSuccessFlow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ServicePaymentSuccessBottomSheet(
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: AppTextStyles.h2),
        const SizedBox(height: 24),
        _buildRecipientField(),
        if (widget.showPlanSelector && widget.plans != null) ...[
          const SizedBox(height: 24),
          Text('Choose a plan', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          _buildPlanList(),
        ],
        const SizedBox(height: 24),
        Text('Choose amount', style: AppTextStyles.bodyLarge),
        const SizedBox(height: 12),
        _buildAmountGrid(),
        const SizedBox(height: 24),
        _buildAmountEntryCard(),
        const SizedBox(height: 24),
        _buildRecipientDropdown(),
        const SizedBox(height: 16),
        _buildBeneficiaryList(),
        const SizedBox(height: 24),
        PrimaryButton(
          label: widget.actionButtonLabel,
          onPressed: _showPaymentFlow,
        ),
      ],
    );
  }

  Widget _buildRecipientField() {
    return AppTextField(
      label: widget.recipientLabel,
      hint: widget.recipientHint,
      controller: _recipientController,
      keyboardType: TextInputType.phone,
      suffixIcon: IconButton(
        onPressed: () {
          // Future contact picker
        },
        icon: const Icon(Icons.contacts_outlined, color: AppColors.primary),
      ),
      prefix: GestureDetector(
        onTap: () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.providerOptions.map((provider) {
                  return ListTile(
                    title: Text(provider),
                    onTap: () => Navigator.pop(context, provider),
                  );
                }).toList(),
              );
            },
          );
          if (selected != null) {
            setState(() {
              _selectedProvider = selected;
            });
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(widget.serviceIcon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    _selectedProvider ?? widget.providerLabel,
                    style: AppTextStyles.bodyRegular,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList() {
    return Column(
      children: widget.plans!.map((plan) {
        final selectedPlan = plan.title == _selectedPlan;
        return GestureDetector(
          onTap: () => setState(() => _selectedPlan = plan.title),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: selectedPlan
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedPlan ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  plan.price,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: widget.presetAmounts.map((value) {
        return GestureDetector(
          onTap: () => _setAmount(value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              color: AppColors.surface,
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: '₦',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: value.toStringAsFixed(0),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountEntryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter amount', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('₦', style: AppTextStyles.bodyLarge),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                      ),
                      style: AppTextStyles.h3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(widget.walletBalance, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedBeneficiary,
                hint: const Text('Choose beneficiary'),
                items: _currentBeneficiaries
                    .map(
                      (recipient) => DropdownMenuItem<String>(
                        value: recipient.number,
                        child: Text(
                          '${recipient.number} • ${recipient.provider}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    final recipient = _currentBeneficiaries.firstWhere(
                      (item) => item.number == value,
                      orElse: () => _currentBeneficiaries.first,
                    );
                    setState(() {
                      _selectedBeneficiary = value;
                      _recipientController.text = recipient.number;
                      _selectedProvider = recipient.provider;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: _clearBeneficiaries,
          child: Text(
            'Delete All',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildBeneficiaryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent beneficiaries', style: AppTextStyles.bodyLarge),
        const SizedBox(height: 12),
        ...List.generate(_currentBeneficiaries.length, (index) {
          final beneficiary = _currentBeneficiaries[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(beneficiary.number, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      beneficiary.provider,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _removeBeneficiary(index),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ServicePaymentDetailsBottomSheet extends StatelessWidget {
  final String title;
  final String recipient;
  final String provider;
  final String amount;
  final String paymentMethod;
  final VoidCallback onPay;

  const ServicePaymentDetailsBottomSheet({
    super.key,
    required this.title,
    required this.recipient,
    required this.provider,
    required this.amount,
    required this.paymentMethod,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Review $title payment',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _detailRow('Recipient', recipient),
            const SizedBox(height: 12),
            _detailRow('Provider', provider),
            const SizedBox(height: 12),
            _detailRow('Amount', amount),
            const SizedBox(height: 12),
            _detailRow('Payment method', paymentMethod),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Pay', onPressed: onPay),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class ServicePaymentPinBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const ServicePaymentPinBottomSheet({super.key, required this.onSuccess});

  @override
  State<ServicePaymentPinBottomSheet> createState() =>
      _ServicePaymentPinBottomSheetState();
}

class _ServicePaymentPinBottomSheetState
    extends State<ServicePaymentPinBottomSheet> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter payment PIN',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Payment PIN',
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Confirm Payment',
              onPressed: () {
                if (_pinController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your PIN')),
                  );
                  return;
                }
                widget.onSuccess();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicePaymentSuccessBottomSheet extends StatelessWidget {
  final VoidCallback onClose;

  const ServicePaymentSuccessBottomSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment successful!',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment was completed successfully.',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Download Receipt', onPressed: () {}),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClose,
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
