import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class CreateRecurringPaymentView extends StatefulWidget {
  const CreateRecurringPaymentView({super.key});

  @override
  State<CreateRecurringPaymentView> createState() =>
      _CreateRecurringPaymentViewState();
}

class _CreateRecurringPaymentViewState extends State<CreateRecurringPaymentView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController meterNumberController;
  late TextEditingController amountController;

  String? selectedBiller;
  String? selectedDuration;
  DateTime? selectedStartDate;

  final List<String> billers = ['NEPA', 'Dstv', 'Gotv', 'Startimes'];
  final List<String> durations = ['Weekly', 'Monthly', 'Quarterly', 'Annual'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    meterNumberController = TextEditingController();
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    meterNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  void _showPaymentDetailsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PaymentDetailsBottomSheet(
        biller: selectedBiller ?? 'N/A',
        meterNumber: meterNumberController.text,
        amount: double.tryParse(amountController.text) ?? 0,
        duration: selectedDuration ?? 'N/A',
        startDate: selectedStartDate ?? DateTime.now(),
        type: _tabController.index == 0 ? 'Prepaid' : 'Postpaid',
        onPay: () {
          Navigator.pop(context);
          _showPaymentPinBottomSheet();
        },
      ),
    );
  }

  void _showPaymentPinBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PaymentPinBottomSheet(
        onPaymentSuccess: () {
          Navigator.pop(context);
          _showSuccessBottomSheet();
        },
      ),
    );
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PaymentSuccessBottomSheet(
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Create Recurring Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TabBar for Prepaid/Postpaid
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Prepaid'),
                  Tab(text: 'Postpaid'),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            // Biller Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Biller', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBiller,
                    hint: const Text('Select Biller'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: billers
                        .map(
                          (biller) => DropdownMenuItem(
                            value: biller,
                            child: Text(biller),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedBiller = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meter Number
            AppTextField(
              label: 'Meter Number',
              controller: meterNumberController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Amount
            AppTextField(
              label: 'Amount',
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Duration Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Duration', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedDuration,
                    hint: const Text('Select Duration'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: durations
                        .map(
                          (duration) => DropdownMenuItem(
                            value: duration,
                            child: Text(duration),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedDuration = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Start Date Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Start Date', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedStartDate != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(selectedStartDate!)
                              : 'Select Date',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: selectedStartDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Pay Button
            PrimaryButton(
              label: 'Pay',
              onPressed: () {
                if (selectedBiller == null ||
                    meterNumberController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    selectedDuration == null ||
                    selectedStartDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }
                _showPaymentDetailsBottomSheet();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentDetailsBottomSheet extends StatelessWidget {
  final String biller;
  final String meterNumber;
  final double amount;
  final String duration;
  final DateTime startDate;
  final String type;
  final VoidCallback onPay;

  const PaymentDetailsBottomSheet({
    super.key,
    required this.biller,
    required this.meterNumber,
    required this.amount,
    required this.duration,
    required this.startDate,
    required this.type,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Review Payment Details',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Biller', value: biller),
                const Divider(height: 16),
                _DetailRow(label: 'Type', value: type),
                const Divider(height: 16),
                _DetailRow(label: 'Meter Number', value: meterNumber),
                const Divider(height: 16),
                _DetailRow(
                  label: 'Amount',
                  value: '₦${amount.toStringAsFixed(2)}',
                ),
                const Divider(height: 16),
                _DetailRow(label: 'Duration', value: duration),
                const Divider(height: 16),
                _DetailRow(
                  label: 'Start Date',
                  value: DateFormat('MMM dd, yyyy').format(startDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Payment Method
          const Text('Payment Method', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Balance',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        '₦5,000.00',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Continue to Payment', onPressed: onPay),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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

class PaymentPinBottomSheet extends StatefulWidget {
  final VoidCallback onPaymentSuccess;

  const PaymentPinBottomSheet({super.key, required this.onPaymentSuccess});

  @override
  State<PaymentPinBottomSheet> createState() => _PaymentPinBottomSheetState();
}

class _PaymentPinBottomSheetState extends State<PaymentPinBottomSheet> {
  late TextEditingController pinController;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter Payment PIN',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Payment PIN',
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Confirm Payment',
            onPressed: () {
              if (pinController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your PIN')),
                );
                return;
              }
              widget.onPaymentSuccess();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class PaymentSuccessBottomSheet extends StatelessWidget {
  final VoidCallback onClose;

  const PaymentSuccessBottomSheet({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, color: AppColors.white, size: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Successful!',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your recurring payment has been set up successfully',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Download Receipt',
            onPressed: () {
              // TODO: Implement download receipt
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onClose,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Close',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
