import 'dart:math';

import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/services/data/models/service_model.dart';
import 'package:blithepay/features/services/presentation/bloc/cable_tv_bloc/cable_tv_bloc.dart';
import 'package:blithepay/features/services/presentation/bloc/service_bloc/service_bloc.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceView<TBloc extends BlocBase<TState>, TState>
    extends StatelessWidget {
  final String title;

  final Widget Function(BuildContext, TState) formBuilder;
  final Widget Function(BuildContext, TState) overlayBuilder;

  const ServiceView({
    super.key,
    required this.title,
    required this.formBuilder,
    required this.overlayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: true,
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const BodySm('Services'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<TBloc, TState>(
          builder: (context, state) {
            final hasSelectedProvider =
                state is ServiceState &&
                state.selectedProvider != null &&
                state.selectedProvider!.isNotEmpty;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      buildProviderSelection(context, state),
                      const SizedBox(height: 24),
                      if (hasSelectedProvider) ...[
                        const SizedBox(height: 24),
                        formBuilder(context, state),
                      ],
                    ],
                  ),
                ),
                overlayBuilder(context, state),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget buildProviderSelection(BuildContext context, dynamic state) {
  // 1. Type Guard: Verify that the state parameter is valid
  if (state is! ServiceState && state is! CableTvState) {
    return const SizedBox.shrink();
  }

  // 2. Polymorphic Extraction: Normalize all UI properties dynamically
  final String providerLabel = state is ServiceState
      ? state.config.providerLabel
      : 'Select Provider';
  final String? selectedProvider = state.selectedProvider;
  final bool isLoading = state is ServiceState
      ? state.isProvidersLoading
      : state.isProvidersLoading;
  final String? errorMessage = state.errorMessage;

  // Normalize provider data models safely
  final List<dynamic> providers = state.providers.isNotEmpty
      ? state.providers
      : (state is ServiceState
            ? state.config.providerOptions
                  .map((name) => ServiceProviderModel(id: name, name: name))
                  .toList()
            : const []);

  // ── LOADING STATE ──────────────────────────────────────────────────────────
  if (isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          providerLabel,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ShimmerWidget.buildShimmerRow(
          itemCount: max(3, min(5, providers.length)),
          itemWidth: 110,
          itemHeight: 44,
          spacing: 12,
          borderRadius: BorderRadius.circular(14),
        ),
      ],
    );
  }

  // ── ERROR STATE ────────────────────────────────────────────────────────────
  if (errorMessage != null && errorMessage.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          providerLabel,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            errorMessage,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () {
              if (state is CableTvState) {
                context.read<CableTvBloc>().add(CableTvInitRequested());
              } else if (state is ServiceState) {
                final serviceId = state.selectedProviderId;
                if (serviceId != null && serviceId.isNotEmpty) {
                  context.read<ServiceBloc>().add(
                    ServiceProvidersRequested(serviceId),
                  );
                }
              }
            },
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  // ── IDLE / SUCCESS CONTENT RENDER ──────────────────────────────────────────
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        providerLabel,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: providers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final provider = providers[index];
            final isSelected = provider.name == selectedProvider;

            return GestureDetector(
              onTap: () {
                // Polymorphic Event Dispatching matching the accurate state engine
                if (state is CableTvState) {
                  context.read<CableTvBloc>().add(
                    CableTvProviderSelected(provider.id),
                  );
                } else if (state is ServiceState) {
                  context.read<ServiceBloc>().add(
                    ServiceProviderSelected(
                      provider.name,
                      providerId: state.providers.isNotEmpty
                          ? provider.id
                          : null,
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 95,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.05)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.7),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child:
                              provider.logo != null && provider.logo!.isNotEmpty
                              ? Image.network(
                                  provider.logo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholderLetter(provider.name),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary
                                                        .withOpacity(0.5),
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : _buildPlaceholderLetter(provider.name),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildPlaceholderLetter(String name) {
  final cleanName = name.trim().toUpperCase();
  final displayLetter = cleanName.isNotEmpty ? cleanName[0] : '?';
  return Text(
    displayLetter,
    style: TextStyle(
      fontWeight: FontWeight.w900,
      color: AppColors.primary.withOpacity(0.6),
      fontSize: 16,
    ),
  );
}
