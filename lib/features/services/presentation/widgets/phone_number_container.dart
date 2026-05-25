import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/services/presentation/views/airtime/widget/amount_entry_card.dart';
import 'package:blithepay/features/services/presentation/widgets/top_off_grid.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/inputs/phone_number_field.dart';
import 'package:flutter/material.dart';

class PhoneNumberContainer extends StatelessWidget {
  final ServiceState state;
  final TextEditingController phoneController;
  final TextEditingController amountController;

  const PhoneNumberContainer({
    super.key,
    required this.state,
    required this.phoneController,
    required this.amountController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recipient phone number', style: AppTextStyles.bodyLarge),

        const SizedBox(height: 12),
        PhoneNumberField(
          controller: phoneController,
          isBeneficiaryListVisible: state.isBeneficiaryListVisible,
          onBeneficiariesToggle: () {
            context.read<ServiceBloc>().add(ServiceBeneficiaryListToggled());
          },
          onChanged: (value) {
            context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
          },
        ),
        if (state.isBeneficiaryListVisible) ...[
          const SizedBox(height: 18),
          // BeneficiaryList(
          //   beneficiaries: state.beneficiaries,
          //   onSelect: (b) {
          //     context.read<AirtimeBloc>().add(AirtimeBeneficiarySelected(b));
          //   },
          //   onRemove: (id) {
          //     context.read<AirtimeBloc>().add(AirtimeBeneficiaryRemoved(id));
          //   },
          //   onDeleteAll: () {
          //     context.read<AirtimeBloc>().add(
          //       const AirtimeBeneficiariesCleared(),
          //     );
          //   },
          // ),
        ],
        const SizedBox(height: 26),
        const Text('Top Off', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 14),
        TopOffGrid(
          selectedAmountKobo: state.amountKobo,
          onAmountSelected: (value) {
            amountController.text = _formatAmount(value);
            context.read<ServiceBloc>().add(ServiceAmountSelected(value));
          },
        ),
        const SizedBox(height: 24),

        AmountEntryCard(controller: amountController),
        const SizedBox(height: 24),
        PrimaryButton(
          //  onPressed: () {
          onPressed: () {
            final bloc = context.read<ServiceBloc>();

            //bloc.add(ServiceReviewRequested());

            context.push('/service/review', extra: bloc);
          },
          //    context.read<ServiceBloc>().add(ServiceReviewRequested());
          //      },
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
