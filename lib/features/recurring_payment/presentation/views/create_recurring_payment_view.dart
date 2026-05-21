import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
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
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
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
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Create Recurring Payment'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biller Dropdown
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
                      (biller) =>
                          DropdownMenuItem(value: biller, child: Text(biller)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedBiller = value);
                },
              ),
            ),
            const SizedBox(height: 16),

            // TabBar for Prepaid/Postpaid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                tabs: const [
                  Tab(text: 'Prepaid'),
                  Tab(text: 'Postpaid'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPrepaidView(), _buildPostpaidView()],
              ),
            ),

            // Pay Button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: PrimaryButton(
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
      ),
    );
  }

  _buildPrepaidView() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  _buildPostpaidView() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
        ],
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
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackArrowButtonIcon(),
            Text(
              '₦${amount.toStringAsFixed(2)}',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Details Card
            Column(
              children: [
                _DetailRow(label: 'Biller', value: biller),
                const SizedBox(height: 16),

                _DetailRow(label: 'Type', value: type),
                const SizedBox(height: 16),

                _DetailRow(label: 'Meter Number', value: meterNumber),
                const SizedBox(height: 16),

                _DetailRow(
                  label: 'Amount',
                  value: '₦${amount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),

                _DetailRow(label: 'Duration', value: duration),
                const SizedBox(height: 16),

                _DetailRow(
                  label: 'Start Date',
                  value: DateFormat('MMM dd, yyyy').format(startDate),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Payment Method
            const BalancePaymentCard(),

            // const Text('Payment Method', style: AppTextStyles.bodyLarge),
            // const SizedBox(height: 12),
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: AppColors.border),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.account_balance_wallet, size: 24),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             const Text(
            //               'Wallet Balance',
            //               style: AppTextStyles.bodyMedium,
            //             ),
            //             Text(
            //               '₦5,000.00',
            //               style: AppTextStyles.bodySmall.copyWith(
            //                 color: AppColors.textSecondary,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Pay', onPressed: onPay),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class BalancePaymentCard extends StatelessWidget {
  const BalancePaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available balance',
                    style: TextStyle(
                      color: Color(0xFF55555D),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₦94,552.72',
                    style: TextStyle(
                      color: Color(0xFF061657),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Divider(color: Color(0xFFE4E7F1), height: 1),
                  SizedBox(height: 14),
                  Text(
                    '-₦2000.00',
                    style: TextStyle(
                      color: Color(0xFF061657),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4B4B52),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF061657),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
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
