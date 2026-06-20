import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/vas/core/data/models/beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:blithepay/features/vas/core/utils/network_detector.dart';
import 'package:blithepay/shared/widgets/bottom_sheets/contact_picker_sheet.dart';
import 'package:blithepay/shared/widgets/inputs/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Reusable phone-number section used by every service form.
///
/// Renders:
///   • [PhoneNumberField] with network badge + contact-picker button
///   • Network-detected label (brand colour, only when [ServiceState.network] set)
///   • Horizontal recent-beneficiaries chip row (only when list is non-empty)
///
/// Callers must supply a [phoneController] that they own and dispose.
class ServicePhoneSection extends StatelessWidget {
  final ServiceState state;
  final TextEditingController phoneController;

  const ServicePhoneSection({
    super.key,
    required this.state,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final currentProvider = state.providers.firstWhere(
      (p) => p.name == state.selectedProvider,
      orElse: () => ServiceProviderModel(id: '', name: ''),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Phone field ────────────────────────────────────────────────────
        PhoneNumberField(
          controller: phoneController,
          detectedNetwork: state.network,
          onChanged: (value) {
            context.read<ServiceBloc>().add(ServiceRecipientChanged(value));
            context.read<ServiceBloc>().add(
              ServiceNetworkDetected(detectNigerianNetwork(value)),
            );
          },
          prefixIcon: currentProvider.name.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child:
                        currentProvider.logo != null &&
                            currentProvider.logo!.isNotEmpty
                        ? Image.network(
                            currentProvider.logo!,
                            fit: BoxFit.cover,
                          )
                        : Center(child: Text(currentProvider.name[0])),
                  ),
                )
              : null,
          onContactPickerTap: () => _openContactPicker(context),
        ),

        // ── Network label ──────────────────────────────────────────────────
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

        // ── Recent beneficiaries ───────────────────────────────────────────
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
      ],
    );
  }

  Future<void> _openContactPicker(BuildContext context) async {
    final bloc = context.read<ServiceBloc>();

    var status = await Permission.contacts.status;
    if (status.isDenied) status = await Permission.contacts.request();

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts access is blocked. Enable it in Settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
      return;
    }

    if (!status.isGranted || !context.mounted) return;

    final selectedPhone = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ContactPickerSheet(),
    );

    if (selectedPhone == null || !context.mounted) return;

    final clean = selectedPhone.replaceAll(RegExp(r'[^\d ]'), '').trim();
    phoneController.text = clean;
    bloc.add(ServiceRecipientChanged(clean));
    bloc.add(ServiceNetworkDetected(detectNigerianNetwork(clean)));
  }
}

// ── Recent contacts strip ────────────────────────────────────────────────────

class _RecentContacts extends StatelessWidget {
  final List<Beneficiary> beneficiaries;
  final ValueChanged<Beneficiary> onSelect;

  const _RecentContacts({required this.beneficiaries, required this.onSelect});

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
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                networkShortLabel(beneficiary.network),
                style: const TextStyle(
                  color: AppColors.primary,
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
