import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/services/data/models/cable_tv_models.dart';
import 'package:blithepay/features/services/data/models/service_model.dart';
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
import 'package:blithepay/features/services/presentation/bloc/cable_tv_bloc/cable_tv_bloc.dart';
import 'package:blithepay/features/services/presentation/views/shared/receipt_services.dart';
import 'package:blithepay/features/services/presentation/views/shared/success_panel.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/features/services/presentation/widgets/purchase_overlay.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Root ──────────────────────────────────────────────────────────────────────

class CableTvServiceView extends StatelessWidget {
  final ServiceEntity? service;

  const CableTvServiceView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    // 1. Grab dynamic wallet balance from active Dashboard state provider scope

    return BlocProvider(
      create: (context) =>
          CableTvBloc(
            serviceRepository: context.read<ServiceRepository>(),
            serviceId: service
                ?.id, // Pass service ID to trigger network providers endpoint
            availableBalanceKobo: 9455272,
            recentSmartcards: const [
              CableTvSmartcard(
                id: '1',
                smartcardNumber: '00012345678',
                provider: 'DStv',
                customerName: 'John Doe',
                packageName: 'Compact',
              ),
              CableTvSmartcard(
                id: '2',
                smartcardNumber: '00056789012',
                provider: 'GOtv',
                customerName: 'Jane Smith',
                packageName: 'Max',
              ),
            ],
          )..add(
            CableTvInitRequested(),
          ), // 2. Dispatch immediate initialization event
      child: const _CableTvScreen(),
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class _CableTvScreen extends StatefulWidget {
  const _CableTvScreen();

  @override
  State<_CableTvScreen> createState() => _CableTvScreenState();
}

class _CableTvScreenState extends State<_CableTvScreen> {
  final _smartcardCtrl = TextEditingController();

  @override
  void dispose() {
    _smartcardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CableTvBloc, CableTvState>(
      listenWhen: (previous, current) =>
          previous.isSuccess != current.isSuccess ||
          previous.smartcardNumber != current.smartcardNumber,
      listener: (context, state) {
        if (_smartcardCtrl.text != state.smartcardNumber) {
          _smartcardCtrl.text = state.smartcardNumber;
        }
        if (state.isSuccess) {
          _showSuccessPanel(context, state.transaction);
        }
      },
      child: BlocBuilder<CableTvBloc, CableTvState>(
        builder: (context, state) {
          return AppScaffold(
            title: 'Cable TV',
            onBackPressed: () {
              if (state.step == CableTvStep.smartcard) {
                Navigator.of(context).pop();
              } else {
                context.read<CableTvBloc>().add(CableTvBack());
              }
            },
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cable TV',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _StepIndicator(currentStep: state.step),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _buildStep(context, state),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(BuildContext context, CableTvState state) {
    return switch (state.step) {
      CableTvStep.smartcard => _SmartcardStep(
        key: const ValueKey(CableTvStep.smartcard),
        state: state,
        controller: _smartcardCtrl,
      ),
      CableTvStep.packageSelect => _PackageStep(
        key: const ValueKey(CableTvStep.packageSelect),
        state: state,
      ),
      CableTvStep.confirmation => _ConfirmationStep(
        key: const ValueKey(CableTvStep.confirmation),
        state: state,
        onPay: () => _showPinSheet(context),
      ),
    };
  }

  void _showPinSheet(BuildContext context) {
    final bloc = context.read<CableTvBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<CableTvBloc, CableTvState>(
          listener: (modalCtx, state) {
            final hasTransaction = state.transaction != null;
            final hasError =
                state.errorMessage.isNotEmpty && !state.isProcessing;

            if (hasTransaction) {
              Navigator.of(modalCtx).pop();
              _showSuccessPanel(context, state.transaction!);
              return;
            }

            if (hasError) {
              Navigator.of(modalCtx, rootNavigator: true).pop();
            }
          },
          builder: (modalCtx, state) {
            return PurchaseProcessingOverlay(
              visible: state.isProcessing,
              child: PinBottomSheetContent(
                isLoading: state.isProcessing,
                errorMessage: state.errorMessage,
                onSubmit: (pin) async {
                  modalCtx.read<CableTvBloc>().add(CableTvPayRequested(pin));
                },
                onForgotPin: () {},
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSuccessPanel(BuildContext context, dynamic transaction) {
    final bloc = context.read<CableTvBloc>();
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => SuccessPanel(
        title: 'Payment Successful!',
        description: 'Your Cable TV subscription is now active.',
        transaction: transaction,
        onDownloadReceipt: () async {
          if (transaction != null) {
            final currentState = context.read<CableTvBloc>().state;
            await _showReceiptPreviewDialog(
              context,
              transaction,
              smartcardNumber: currentState.smartcardNumber,
              provider: currentState.selectedProvider,
            );
          }
        },
        onGoHome: () {
          Navigator.pop(context); // close success sheet
          Navigator.pop(context); // pop cable TV view screen
          bloc.add(CableTvSuccessDismissed());
        },
      ),
    );
  }

  Future<void> _showReceiptPreviewDialog(
    BuildContext context,
    dynamic transaction, {
    String smartcardNumber = '',
    String provider = '',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Receipt Preview',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ref: ${transaction.reference}',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (transaction.status as String).toUpperCase(),
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₦${(transaction.amount as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _SummaryRow('Reference', transaction.reference as String),
                    _SummaryRow('Status', transaction.status as String),
                    if (smartcardNumber.isNotEmpty)
                      _SummaryRow('Smartcard', smartcardNumber),
                    if (provider.isNotEmpty) _SummaryRow('Provider', provider),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryOutlinedButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            label: 'Close',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Download PDF',
                            onPressed: () async {
                              Navigator.pop(dialogCtx);
                              if (transaction != null) {
                                await ReceiptService.download(
                                  transaction: transaction,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // end _CableTvScreenState

// ── Step indicator ────────────────────────────────────────────────────────────

enum _NodeState { completed, active, pending }

class _StepIndicator extends StatelessWidget {
  final CableTvStep currentStep;

  const _StepIndicator({required this.currentStep});

  int get _idx => CableTvStep.values.indexOf(currentStep);

  @override
  Widget build(BuildContext context) {
    const labels = ['Smartcard', 'Package', 'Confirm'];
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          _StepNode(
            index: i,
            label: labels[i],
            nodeState: i < _idx
                ? _NodeState.completed
                : i == _idx
                ? _NodeState.active
                : _NodeState.pending,
          ),
          if (i < labels.length - 1)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                color: i < _idx ? AppColors.primary : const Color(0xFFDCDFEB),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  final int index;
  final String label;
  final _NodeState nodeState;

  const _StepNode({
    required this.index,
    required this.label,
    required this.nodeState,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = nodeState == _NodeState.pending;
    final isCompleted = nodeState == _NodeState.completed;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPending ? Colors.transparent : AppColors.primary,
            border: isPending
                ? Border.all(color: const Color(0xFFDCDFEB), width: 1.5)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 14,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isPending
                          ? const Color(0xFFBBC2D8)
                          : AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isPending ? AppColors.textTertiary : AppColors.primary,
            fontSize: 10,
            fontWeight: nodeState == _NodeState.active
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Smartcard ─────────────────────────────────────────────────────────

class _SmartcardStep extends StatelessWidget {
  final CableTvState state;
  final TextEditingController controller;

  const _SmartcardStep({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always show the dynamic reusable provider row/grid selection first
        _ProviderChipRow(
          providers: state.providers,
          selected: state.selectedProvider,
          onSelected: (provider) {
            context.read<CableTvBloc>().add(
              CableTvProviderSelected(provider.name, providerId: provider.id),
            );
          },
        ),
        // Use an AnimatedSwitcher or visibility check to reveal the rest of the form
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: const ValueKey('smartcard_form_fields'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const Text('Smartcard Number', style: AppTextStyles.headingSmall),
              const SizedBox(height: 10),

              _SmartcardField(
                controller: controller,
                state: state,
                onChanged: (v) =>
                    context.read<CableTvBloc>().add(CableTvSmartcardChanged(v)),
              ),

              if (state.verifyError != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 13,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.verifyError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (state.recentSmartcards.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SmartcardChipsRow(
                  smartcards: state.recentSmartcards,
                  onTap: (sc) => _showBeneficiarySheet(context, sc),
                ),
              ],

              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Verify Smartcard',
                isLoading: state.isVerifying,
                onPressed: !state.isVerifying
                    ? () => context.read<CableTvBloc>().add(
                        CableTvVerifyRequested(),
                      )
                    : () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBeneficiarySheet(BuildContext context, CableTvSmartcard sc) {
    final bloc = context.read<CableTvBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BeneficiaryActionSheet(
        smartcard: sc,
        onRenew: () {
          Navigator.pop(context);
          bloc.add(CableTvBeneficiaryRenewSelected(sc));
        },
        onChange: () {
          Navigator.pop(context);
          bloc.add(CableTvBeneficiaryChangeSelected(sc));
        },
      ),
    );
  }
}

class _SmartcardField extends StatelessWidget {
  final TextEditingController controller;
  final CableTvState state;
  final ValueChanged<String> onChanged;

  const _SmartcardField({
    required this.controller,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    if (state.customer != null) {
      borderColor = AppColors.success;
    } else if (state.verifyError != null) {
      borderColor = AppColors.error;
    } else {
      borderColor = AppColors.primary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _ProviderBadge(provider: state.selectedProvider),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 1,
            height: 22,
            color: AppColors.border,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: '0000000000',
                hintStyle: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SmartcardStatusIcon(state: state),
        ],
      ),
    );
  }
}

class _SmartcardStatusIcon extends StatelessWidget {
  final CableTvState state;

  const _SmartcardStatusIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isVerifying) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }
    if (state.customer != null) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 20,
      );
    }
    if (state.verifyError != null) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
    }
    return const Icon(
      Icons.sim_card_outlined,
      color: AppColors.textTertiary,
      size: 20,
    );
  }
}

class _ProviderChipRow extends StatelessWidget {
  final List<dynamic> providers;
  final String selected;
  final ValueChanged<dynamic> onSelected;

  const _ProviderChipRow({
    required this.providers,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: providers.map((provider) {
          final isSelected = provider.name == selected;
          final hasLogo = provider.logo != null && provider.logo!.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(provider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFF0F1F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE3E7F2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Network Logo Circle
                    if (hasLogo) ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          provider.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.tv, size: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      provider.name,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SmartcardChipsRow extends StatelessWidget {
  final List<CableTvSmartcard> smartcards;
  final ValueChanged<CableTvSmartcard> onTap;

  const _SmartcardChipsRow({required this.smartcards, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous',
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
            itemCount: smartcards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _SmartcardChip(
              smartcard: smartcards[i],
              onTap: () => onTap(smartcards[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmartcardChip extends StatelessWidget {
  final CableTvSmartcard smartcard;
  final VoidCallback onTap;

  const _SmartcardChip({required this.smartcard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = smartcard.smartcardNumber;
    final suffix = n.length >= 4 ? n.substring(n.length - 4) : n;

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
                smartcard.provider.length >= 2
                    ? smartcard.provider.substring(0, 2).toUpperCase()
                    : smartcard.provider.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
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

// ── Step 2: Package selection ─────────────────────────────────────────────────

class _PackageStep extends StatelessWidget {
  final CableTvState state;

  const _PackageStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.customer != null) ...[
          _CustomerCard(
            customer: state.customer!,
            provider: state.selectedProvider,
          ),
          const SizedBox(height: 24),
        ],

        const Text('Select Package', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),

        Container(
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBF5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              itemCount: state.packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _PackageCard(
                package: state.packages[i],
                isSelected: i == state.selectedPackageIndex,
                onTap: () =>
                    context.read<CableTvBloc>().add(CableTvPackageSelected(i)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        PrimaryButton(
          label: 'Continue',
          onPressed: () =>
              context.read<CableTvBloc>().add(CableTvContinueToConfirmation()),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CableTvCustomer customer;
  final String provider;

  const _CustomerCard({required this.customer, required this.provider});

  @override
  Widget build(BuildContext context) {
    final statusColor = customer.status == 'Active'
        ? AppColors.success
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _ProviderBadge(provider: provider),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AppTextStyles.headingSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${customer.currentPackage} · ',
                      style: AppTextStyles.bodySmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        customer.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Due: ${customer.dueDate}', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final ServiceProductModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8EBF5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _RadioDot(isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        package.name,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.priceLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 3: Confirmation ──────────────────────────────────────────────────────

class _ConfirmationStep extends StatelessWidget {
  final CableTvState state;
  final VoidCallback onPay;

  const _ConfirmationStep({
    super.key,
    required this.state,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = state.selectedPackage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Summary', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),

        _OrderSummaryCard(state: state),

        const SizedBox(height: 16),

        _WalletCard(state: state),

        const SizedBox(height: 28),

        PrimaryButton(
          label: pkg != null ? 'Pay ${state.formattedAmount}' : 'Pay',
          onPressed: onPay,
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CableTvState state;

  const _OrderSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final pkg = state.selectedPackage;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBF5)),
      ),
      child: Column(
        children: [
          _SummaryRow('Smartcard', state.smartcardNumber),
          _SummaryRow('Customer', state.customer?.name ?? '—'),
          _SummaryRow('Provider', state.selectedProvider),
          _SummaryRow('Package', pkg?.name ?? '—'),
          _SummaryRow('Amount', pkg?.priceLabel ?? '—', isAmount: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAmount;

  const _SummaryRow(this.label, this.value, {this.isAmount = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyRegular),
          Text(
            value,
            style: isAmount
                ? const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )
                : AppTextStyles.bodyRegularBlack,
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final CableTvState state;

  const _WalletCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.read<DashboardBloc>().state;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet Balance', style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  dashboardState is DashboardLoaded
                      ? dashboardState.dashboard.walletBalance
                      : '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Debit', style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                '-${state.formattedAmount}',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Beneficiary action sheet ──────────────────────────────────────────────────

class _BeneficiaryActionSheet extends StatelessWidget {
  final CableTvSmartcard smartcard;
  final VoidCallback onRenew;
  final VoidCallback onChange;

  const _BeneficiaryActionSheet({
    required this.smartcard,
    required this.onRenew,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final n = smartcard.smartcardNumber;
    final suffix = n.length >= 4 ? n.substring(n.length - 4) : n;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                _ProviderBadge(provider: smartcard.provider),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•••• •••• $suffix',
                      style: AppTextStyles.headingSmall,
                    ),
                    Text(
                      '${smartcard.customerName} · ${smartcard.provider} · ${smartcard.packageName}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            SecondaryOutlinedButton(
              height: 52,
              onPressed: onChange,
              label: 'Change Package',
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Renew Plan', onPressed: onRenew),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _ProviderBadge extends StatelessWidget {
  final String provider;

  const _ProviderBadge({required this.provider});

  @override
  Widget build(BuildContext context) {
    final color = _providerColor(provider);
    final label = provider.length >= 2
        ? provider.substring(0, 2).toUpperCase()
        : provider.toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;

  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFBBC2D8),
          width: 1.8,
        ),
      ),
      child: isSelected
          ? const Center(
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.white),
            )
          : null,
    );
  }
}

Color _providerColor(String provider) => switch (provider) {
  'DStv' => const Color(0xFF00308F),
  'GOtv' => const Color(0xFFE87722),
  'Startimes' => const Color(0xFFD72027),
  _ => AppColors.primary,
};
