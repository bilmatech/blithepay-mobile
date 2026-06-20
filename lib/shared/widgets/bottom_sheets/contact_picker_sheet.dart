import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/inputs/phone_number_field.dart';
import 'package:blithepay/features/vas/core/utils/network_detector.dart';
import 'package:blithepay/features/vas/core/data/models/beneficiary_model.dart';

/// Bottom sheet that lists the device's phone contacts and lets the user pick
/// one.  Returns the raw phone number string via [Navigator.pop].
///
/// Uses flutter_contacts v2 with selective property fetching — only
/// [ContactProperty.phone] is requested, so the restricted iOS
/// `com.apple.developer.contacts.notes` entitlement is never triggered.
///
/// Usage:
/// ```dart
/// final phone = await showModalBottomSheet<String>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const ContactPickerSheet(),
/// );
/// ```
class ContactPickerSheet extends StatefulWidget {
  const ContactPickerSheet({super.key});

  @override
  State<ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<ContactPickerSheet> {
  List<_ContactItem> _allItems = [];
  List<_ContactItem> _filtered = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      // v2 API: fetch only phone numbers — no notes, no emails, no addresses.
      // This avoids triggering the restricted iOS contacts.notes entitlement.
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone, ContactProperty.name},
      );

      final items = contacts
          .expand(
            (c) =>
                c.phones.map((p) => _ContactItem(name: c.displayName ?? '', rawNumber: p.number)),
          )
          .where((item) => item.rawNumber.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _allItems = items;
          _filtered = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load contacts.';
          _loading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allItems
          : _allItems
                .where((item) => item.name.toLowerCase().contains(q) || item.rawNumber.contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── drag handle ────────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── header ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 12),
                child: Row(
                  children: [
                    const Text('Select Contact', style: AppTextStyles.headingSmall),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── search ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search name or number…',
                    hintStyle: AppTextStyles.bodyRegular.copyWith(color: AppColors.textTertiary),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // ── body ───────────────────────────────────────────────────────
              Expanded(child: _buildBody(scrollCtrl)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollCtrl) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.bodyRegular),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text('No contacts found', style: AppTextStyles.bodyRegular),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollCtrl,
      itemCount: _filtered.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 72, endIndent: 16, color: AppColors.border),
      itemBuilder: (_, i) => _ContactTile(
        item: _filtered[i],
        onTap: () => Navigator.pop(context, _filtered[i].rawNumber),
      ),
    );
  }
}

// ── data class ───────────────────────────────────────────────────────────────

class _ContactItem {
  final String name;
  final String rawNumber;

  const _ContactItem({required this.name, required this.rawNumber});
}

// ── list tile ────────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final _ContactItem item;
  final VoidCallback onTap;

  const _ContactTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final network = detectNigerianNetwork(item.rawNumber);
    final avatarColor = network != null ? networkColor(network) : AppColors.primary;

    final initials = item.name.trim().isEmpty ? '#' : item.name.trim()[0].toUpperCase();

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: avatarColor.withValues(alpha: 0.12),
        child: Text(
          initials,
          style: TextStyle(color: avatarColor, fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      title: Text(
        item.name.isEmpty ? item.rawNumber : item.name,
        style: AppTextStyles.bodyRegularBlack,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: item.name.isEmpty ? null : Text(item.rawNumber, style: AppTextStyles.bodySmall),
      trailing: network != null ? _NetworkTag(network: network) : null,
    );
  }
}

class _NetworkTag extends StatelessWidget {
  final ServiceNetwork network;

  const _NetworkTag({required this.network});

  @override
  Widget build(BuildContext context) {
    final color = networkColor(network);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        networkFullLabel(network),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
