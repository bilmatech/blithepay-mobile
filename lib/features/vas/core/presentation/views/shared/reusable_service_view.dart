import 'dart:math';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:flutter/material.dart';

// â”€â”€ Provider Selection Config â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ProviderSelectionConfig {
  final String label;
  final String? selectedProvider;
  final bool isLoading;
  final String? errorMessage;
  final List<ServiceProviderModel> providers;
  final void Function(ServiceProviderModel) onSelected;
  final VoidCallback onRetry;

  const ProviderSelectionConfig({
    required this.label,
    required this.selectedProvider,
    required this.isLoading,
    required this.errorMessage,
    required this.providers,
    required this.onSelected,
    required this.onRetry,
  });
}

// â”€â”€ Reusable Service View â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ServiceView extends StatelessWidget {
  final String title;
  final ProviderSelectionConfig providerConfig;
  final Widget child;

  const ServiceView({
    super.key,
    required this.title,
    required this.providerConfig,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedProvider =
        providerConfig.selectedProvider != null &&
        providerConfig.selectedProvider!.isNotEmpty;

    return AppScaffold(
      showBackButton: true,
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const BodySm('Services'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildProviderSelection(context, providerConfig),
              const SizedBox(height: 24),
              if (hasSelectedProvider) ...[
                const SizedBox(height: 24),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSelection(
    BuildContext context,
    ProviderSelectionConfig config,
  ) {
    // â”€â”€ LOADING STATE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (config.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.label,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ShimmerWidget.buildShimmerRow(
            itemCount: max(3, min(5, config.providers.length)),
            itemWidth: 110,
            itemHeight: 44,
            spacing: 12,
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      );
    }

    // â”€â”€ ERROR STATE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (config.errorMessage != null && config.errorMessage!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.label,
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
              config.errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: config.onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    // â”€â”€ IDLE / SUCCESS CONTENT RENDER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
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
            itemCount: config.providers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final provider = config.providers[index];
              final isSelected = provider.name == config.selectedProvider;

              return GestureDetector(
                onTap: () => config.onSelected(provider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 95,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border.withValues(alpha: 0.7),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
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
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                      AppColors.primary
                                                          .withValues(alpha: 0.5),
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
        color: AppColors.primary.withValues(alpha: 0.6),
        fontSize: 16,
      ),
    );
  }
}
