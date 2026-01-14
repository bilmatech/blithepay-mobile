import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';

class FundWalletView extends StatefulWidget {
  const FundWalletView({super.key});

  @override
  State<FundWalletView> createState() => _FundWalletViewState();
}

class _FundWalletViewState extends State<FundWalletView> {
  String _selectedMethod = 'card';
  bool _saveCard = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fund Wallet'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Selection
              Text(
                'Select Method:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMethodButton('Card', 'card')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMethodButton('Bank Transfer', 'bank')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMethodButton('USSD', 'ussd')),
                ],
              ),
              const SizedBox(height: 24),

              // Card Info Section
              if (_selectedMethod == 'card') ...[
                Text(
                  'Card Info:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                const AppTextField(
                  label: 'Card Name',
                  hint: 'Type here',
                  // prefixIcon: Icons.credit_card,
                ),
                const SizedBox(height: 12),
                const AppTextField(
                  label: 'Card Number',
                  hint: '000 0000 00000',
                  //  prefixIcon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Expiry Date',
                        hint: 'DD/MM/YY',
                        keyboardType: TextInputType.datetime,
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'CVV',
                        hint: '000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _saveCard,
                  onChanged: (value) =>
                      setState(() => _saveCard = value ?? false),
                  title: const Text('Save card details'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],

              const SizedBox(height: 24),
              PrimaryButton(label: 'Make Payment', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodButton(String label, String value) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.lightBackground : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              label == 'Card' ? Icons.credit_card : Icons.account_balance,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
