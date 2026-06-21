import 'package:flutter/material.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/vas/core/data/models/contact_beneficiary_model.dart';

class ContactBeneficiariesRow extends StatefulWidget {
  final List<ContactBeneficiary> beneficiaries;
  final ValueChanged<ContactBeneficiary> onTap;
  final VoidCallback onLoadMore;
  final bool isFetchingMore;

  const ContactBeneficiariesRow({
    super.key,
    required this.beneficiaries,
    required this.onTap,
    required this.onLoadMore,
    required this.isFetchingMore,
  });

  @override
  State<ContactBeneficiariesRow> createState() => _ContactBeneficiariesRowState();
}

class _ContactBeneficiariesRowState extends State<ContactBeneficiariesRow> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ContactBeneficiariesRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFetchingMore && !widget.isFetchingMore) {
      _isLoadingTriggered = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && !widget.isFetchingMore && !_isLoadingTriggered) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 100) {
        setState(() {
          _isLoadingTriggered = true;
        });
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Recipients',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.beneficiaries.length + (widget.isFetchingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (i == widget.beneficiaries.length) {
                return const SizedBox(
                  width: 68,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              return _ContactBeneficiaryChip(
                beneficiary: widget.beneficiaries[i],
                onTap: () => widget.onTap(widget.beneficiaries[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContactBeneficiaryChip extends StatelessWidget {
  final ContactBeneficiary beneficiary;
  final VoidCallback onTap;

  const _ContactBeneficiaryChip({
    required this.beneficiary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = beneficiary.contactName?.trim() ?? '';
    final displayName = name.isNotEmpty
        ? (name.split(' ').first)
        : beneficiary.phone.length > 4
            ? '...${beneficiary.phone.substring(beneficiary.phone.length - 4)}'
            : beneficiary.phone;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              displayName,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
