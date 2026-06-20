import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart' as vas_models;
import 'package:blithepay/features/vas/airtime/presentation/widgets/phone_number_container.dart';
import 'package:blithepay/features/vas/core/presentation/bloc/services_cubit/services_cubit.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_widget.dart';
import 'package:flutter/material.dart';

class AirtimePurchaseView extends StatelessWidget {
  final ServiceEntity? service;

  const AirtimePurchaseView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    final ServiceEntity activeService;
    if (service != null) {
      activeService = service!;
    } else {
      final servicesState = context.read<ServicesCubit>().state;
      activeService = servicesState.services.firstWhere(
        (s) => s.slug?.toUpperCase() == 'AIRTIME' || s.type == ServiceType.airtime,
        orElse: () => const ServiceEntity(
          id: '61efaba1da92348f9dde5f6c', // Fallback staging airtime id
          name: 'Mobile Recharge',
          icon: 'assets/icons/airtime.svg',
          type: ServiceType.airtime,
          route: '/service/airtime',
          isActive: true,
          slug: 'AIRTIME',
        ),
      );
    }

    return BlocProvider(
      create: (context) => ServiceBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: activeService.id,
        config: const ServiceConfig(
          title: 'Airtime',
          recipientLabel: 'Phone Number',
          recipientHint: 'Enter phone number',
          providerLabel: 'Select Network',
          providerOptions: ['MTN', 'GLO', 'Airtel', '9mobile'],
          plans: [],
          presetAmounts: [300000, 500000, 850000, 1000000, 1500000, 2000000],
          availableBalanceKobo: 9455272,
        ),
      ),
      child: const _AirtimeView(),
    );
  }
}

class _AirtimeView extends StatefulWidget {
  const _AirtimeView();

  @override
  State<_AirtimeView> createState() => _AirtimeViewState();
}

class _AirtimeViewState extends State<_AirtimeView> {
  TextEditingController? _phoneController;
  TextEditingController? _amountController;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<ServiceBloc>().state;
    _phoneController = TextEditingController(text: initialState.phoneNumber);
    _amountController = TextEditingController(
      text: _amountInputText(initialState.amountKobo),
    );
  }

  @override
  void dispose() {
    _phoneController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

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
        child: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            final hasSelectedProvider = state.selectedProvider.isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Airtime',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProviderSection(context, state),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: hasSelectedProvider ? 1.0 : 0.35,
                    child: AbsorbPointer(
                      absorbing: !hasSelectedProvider,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          AirtimeServiceForm(
                            state: state,
                            phoneController: _ensurePhoneController(state),
                            amountController: _ensureAmountController(state),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProviderSection(BuildContext context, ServiceState state) {
    final providerLabel = state.config.providerLabel;
    
    final List<vas_models.ServiceProviderModel> providers = state.providers.isNotEmpty
        ? state.providers
        : state.config.providerOptions
            .map((name) => vas_models.ServiceProviderModel(id: name, name: name))
            .toList();

    if (state.isProvidersLoading) {
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
          const SizedBox(height: 16),
          Center(
            child: ShimmerWidget.buildShimmerRow(
              itemCount: 4,
              itemWidth: 64,
              itemHeight: 64,
              spacing: 16,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ],
      );
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
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
              state.errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                final serviceId = state.selectedProviderId;
                if (serviceId != null && serviceId.isNotEmpty) {
                  context.read<ServiceBloc>().add(
                    ServiceProvidersRequested(serviceId),
                  );
                }
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

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
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 76,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: providers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final provider = providers[index];
                final isSelected = provider.name == state.selectedProvider;

                return GestureDetector(
                  onTap: () {
                    context.read<ServiceBloc>().add(
                      ServiceProviderSelected(
                        provider.name,
                        providerId: state.providers.isNotEmpty ? provider.id : null,
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: provider.logo != null && provider.logo!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    provider.logo!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildPlaceholderLetter(provider.name),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.primary.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : _buildPlaceholderLetter(provider.name),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
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
        fontSize: 20,
      ),
    );
  }

  String _amountInputText(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }

  TextEditingController _ensurePhoneController(ServiceState state) {
    return _phoneController ??= TextEditingController(text: state.phoneNumber);
  }

  TextEditingController _ensureAmountController(ServiceState state) {
    return _amountController ??= TextEditingController(
      text: _amountInputText(state.amountKobo),
    );
  }
}

class AirtimeServiceForm extends StatefulWidget {
  final ServiceState state;
  final TextEditingController phoneController;
  final TextEditingController amountController;

  const AirtimeServiceForm({
    super.key,
    required this.state,
    required this.phoneController,
    required this.amountController,
  });

  @override
  State<AirtimeServiceForm> createState() => _AirtimeServiceFormState();
}

class _AirtimeServiceFormState extends State<AirtimeServiceForm> {
  @override
  Widget build(BuildContext context) {
    return PhoneNumberContainer(
      state: widget.state,
      phoneController: widget.phoneController,
      amountController: widget.amountController,
    );
  }
}
