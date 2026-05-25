import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/services/data/models/beneficiary_model.dart';
import 'package:flutter/material.dart';

class BeneficiaryList extends StatelessWidget {
  final List<Beneficiary> beneficiaries;
  final ValueChanged<Beneficiary> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onDeleteAll;

  const BeneficiaryList({
    super.key,
    required this.beneficiaries,
    required this.onSelect,
    required this.onRemove,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text('Beneficiary list', style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(height: 18),
          if (beneficiaries.isEmpty)
            const SizedBox(
              height: 88,
              child: Center(
                child: Text(
                  'No beneficiaries yet',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else
            ...beneficiaries.map((beneficiary) {
              return _BeneficiaryRow(
                beneficiary: beneficiary,
                onTap: () => onSelect(beneficiary),
                onRemove: () => onRemove(beneficiary.id),
              );
            }),
          if (beneficiaries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: onDeleteAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6E6E72),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 22),
                label: const Text(
                  'Delete all',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BeneficiaryRow extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BeneficiaryRow({
    required this.beneficiary,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFC7C7C7))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                beneficiary.phoneNumber,
                style: AppTextStyles.bodySmall,
              ),
            ),
            Text(
              _beneficiaryNetworkLabel(beneficiary.network),
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(width: 16),
            IconButton(
              tooltip: 'Remove beneficiary',
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Colors.black, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

String _beneficiaryNetworkLabel(ServiceNetwork network) {
  return switch (network) {
    ServiceNetwork.mtn => 'MTN',
    ServiceNetwork.glo => 'GLO',
    ServiceNetwork.airtel => 'Airtel',
  };
}
