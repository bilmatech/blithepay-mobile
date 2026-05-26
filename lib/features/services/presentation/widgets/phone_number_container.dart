import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/services/data/models/beneficiary_model.dart';
import 'package:blithepay/features/services/presentation/views/airtime/widget/amount_entry_card.dart';
import 'package:blithepay/features/services/presentation/widgets/top_off_grid.dart';
import 'package:blithepay/features/services/utils/network_detector.dart';
import 'package:blithepay/shared/widgets/bottom_sheets/contact_picker_sheet.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/inputs/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
        // ── Section: Recipient ─────────────────────────────────────────────
        const Text('Recipient', style: AppTextStyles.headingSmall),
        const SizedBox(height: 10),

        PhoneNumberField(
          controller: phoneController,
          detectedNetwork: state.network,
          onChanged: (value) {
            context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
            final network = detectNigerianNetwork(value);
            context.read<ServiceBloc>().add(ServiceNetworkDetected(network));
          },
          onContactPickerTap: () => _openContactPicker(context),
        ),

        // ── Network label (shown when detected) ────────────────────────────
        if (state.network != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: networkColor(state.network!),
                ),
                const SizedBox(width: 4),
                Text(
                  '${networkFullLabel(state.network!)} detected',
                  style: TextStyle(
                    color: networkColor(state.network!),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Recent beneficiary chips ───────────────────────────────────────
        if (state.beneficiaries.isNotEmpty) ...[
          const SizedBox(height: 20),
          _RecentContacts(
            beneficiaries: state.beneficiaries,
            onSelect: (b) {
              phoneController.text = b.phoneNumber;
              context.read<ServiceBloc>().add(ServiceBeneficiarySelected(b));
            },
          ),
        ],

        const SizedBox(height: 28),

        // ── Section: Quick Top-off ─────────────────────────────────────────
        const Text('Quick Top-off', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),

        TopOffGrid(
          selectedAmountKobo: state.amountKobo,
          onAmountSelected: (value) {
            amountController.text = _formatAmount(value);
            context.read<ServiceBloc>().add(ServiceAmountSelected(value));
          },
        ),

        const SizedBox(height: 20),

        // ── Amount input ───────────────────────────────────────────────────
        AmountEntryCard(
          controller: amountController,
          availableBalanceKobo: state.availableBalanceKobo,
          onAmountChanged: (value) {
            context.read<ServiceBloc>().add(ServiceAmountSelected(value));
          },
        ),

        const SizedBox(height: 28),

        // ── Pay button ─────────────────────────────────────────────────────
        PrimaryButton(
          label: state.amountKobo > 0
              ? 'Pay ${state.formattedAmount}'
              : 'Pay',
          onPressed: () {
            final bloc = context.read<ServiceBloc>();
            context.push('/service/review', extra: bloc);
          },
        ),
      ],
    );
  }

  Future<void> _openContactPicker(BuildContext context) async {
    final bloc = context.read<ServiceBloc>();

    // ── Permission check ──────────────────────────────────────────────────
    var status = await Permission.contacts.status;

    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Contacts access is blocked. Enable it in Settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return;
    }

    if (!status.isGranted) return;

    if (!context.mounted) return;

    // ── Show picker ───────────────────────────────────────────────────────
    final selectedPhone = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ContactPickerSheet(),
    );

    if (selectedPhone == null || !context.mounted) return;

    phoneController.text = selectedPhone;
    bloc.add(ServiceRecipientChanged(selectedPhone));
    bloc.add(ServiceNetworkDetected(detectNigerianNetwork(selectedPhone)));
  }

  String _formatAmount(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent contacts strip
// ─────────────────────────────────────────────────────────────────────────────

class _RecentContacts extends StatelessWidget {
  final List<Beneficiary> beneficiaries;
  final ValueChanged<Beneficiary> onSelect;

  const _RecentContacts({
    required this.beneficiaries,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: beneficiaries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _BeneficiaryChip(
              beneficiary: beneficiaries[i],
              onTap: () => onSelect(beneficiaries[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _BeneficiaryChip extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;

  const _BeneficiaryChip({required this.beneficiary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = networkColor(beneficiary.network);
    final number = beneficiary.phoneNumber;
    final suffix = number.length >= 4
        ? number.substring(number.length - 4)
        : number;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
            ),
            child: Center(
              child: Text(
                networkShortLabel(beneficiary.network),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '••$suffix',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
