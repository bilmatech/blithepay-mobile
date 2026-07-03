part of 'service_bloc.dart';

enum ServiceStage { entry, pin, success }

enum ServicePlanCategory { daily, weekly, monthly, yearly, unlimited }

class ServiceConfig {
  final String title;
  final String recipientLabel;
  final String recipientHint;
  final String providerLabel;
  final List<String> providerOptions;
  final List<ServicePlan> plans;
  final List<int> presetAmounts;
  final int availableBalanceKobo;

  const ServiceConfig({
    required this.title,
    required this.recipientLabel,
    required this.recipientHint,
    required this.providerLabel,
    required this.providerOptions,
    required this.plans,
    required this.presetAmounts,
    required this.availableBalanceKobo,
  });
}

class ServicePlan {
  final String title;
  final String description;
  final int amountKobo;
  final String bundleCode;

  final String priceLabel;
  final ServicePlanCategory? category;

  const ServicePlan({
    required this.title,
    required this.description,
    required this.amountKobo,
    required this.bundleCode,
    required this.priceLabel,
    this.category,
  });
}

class ServiceState {
  final ServiceConfig config;
  final String recipient;
  final String selectedProvider;
  final String? selectedProviderId;
  final List<ServiceProviderModel> providers;
  final bool isProvidersLoading;
  final List<ServiceProductModel> products;
  final bool isProductsLoading;
  final int amountKobo;
  final int availableBalanceKobo;
  final String pin;
  final ServiceStage stage;
  final int? selectedPlanIndex;
  final bool isBeneficiaryListVisible;
  final String phoneNumber;
  final ServiceNetwork? network;
  final List<Beneficiary> beneficiaries;
  final List<UtilityBeneficiary> utilityBeneficiaries;
  final int utilityBeneficiariesPage;
  final bool hasReachedMaxUtilityBeneficiaries;
  final bool isFetchingMoreUtilityBeneficiaries;
  final List<ContactBeneficiary> contactBeneficiaries;
  final int contactBeneficiariesPage;
  final bool hasReachedMaxContactBeneficiaries;
  final bool isFetchingMoreContactBeneficiaries;
  final bool isProcessing;
  final String? errorMessage;
  final ServiceTransactionModel? transaction;
  final String bundleCode;
  final String meterType;
  final String? verifiedCustomerName;
  final int? minVendAmountKobo;
  final String? contactName;

  const ServiceState({
    required this.config,
    required this.recipient,
    required this.selectedProvider,
    required this.selectedProviderId,
    required this.providers,
    required this.isProvidersLoading,
    required this.products,
    required this.isProductsLoading,
    required this.amountKobo,
    required this.availableBalanceKobo,
    required this.pin,
    required this.stage,
    required this.selectedPlanIndex,
    required this.isBeneficiaryListVisible,
    required this.phoneNumber,
    required this.network,
    required this.beneficiaries,
    required this.utilityBeneficiaries,
    this.utilityBeneficiariesPage = 1,
    this.hasReachedMaxUtilityBeneficiaries = false,
    this.isFetchingMoreUtilityBeneficiaries = false,
    required this.contactBeneficiaries,
    this.contactBeneficiariesPage = 1,
    this.hasReachedMaxContactBeneficiaries = false,
    this.isFetchingMoreContactBeneficiaries = false,
    this.isProcessing = false,
    this.errorMessage = '',
    this.transaction,
    required this.bundleCode,
    required this.meterType,
    this.verifiedCustomerName,
    this.minVendAmountKobo,
    this.contactName,
  });

  factory ServiceState.initial(
    ServiceConfig config, {
    List<Beneficiary> initialBeneficiaries = const [],
  }) {
    final hasPlans = config.plans.isNotEmpty;
    return ServiceState(
      config: config,
      recipient: '',
      selectedProvider: '',
      selectedProviderId: null,
      providers: const [],
      isProvidersLoading: false,
      products: const [],
      isProductsLoading: false,
      amountKobo: hasPlans ? config.plans.first.amountKobo : 0,
      availableBalanceKobo: config.availableBalanceKobo,
      pin: '',
      stage: ServiceStage.entry,
      selectedPlanIndex: hasPlans ? 0 : null,
      isBeneficiaryListVisible: false,
      phoneNumber: '',
      network: null,
      beneficiaries: initialBeneficiaries,
      utilityBeneficiaries: const [],
      utilityBeneficiariesPage: 1,
      hasReachedMaxUtilityBeneficiaries: false,
      isFetchingMoreUtilityBeneficiaries: false,
      contactBeneficiaries: const [],
      contactBeneficiariesPage: 1,
      hasReachedMaxContactBeneficiaries: false,
      isFetchingMoreContactBeneficiaries: false,
      isProcessing: false,
      errorMessage: null,
      transaction: null,
      bundleCode: '',
      meterType: hasPlans ? config.plans.first.title.toLowerCase() : '',
      verifiedCustomerName: null,
      minVendAmountKobo: null,
      contactName: null,
    );
  }

  String get amountWhole => _formatWholeNumber(amountKobo ~/ 100);

  String get amountDecimal =>
      amountKobo.remainder(100).toString().padLeft(2, '0');

  String get formattedAmount => '₦$amountWhole.$amountDecimal';

  String get formattedBalance {
    final whole = _formatWholeNumber(availableBalanceKobo ~/ 100);
    final decimal = availableBalanceKobo
        .remainder(100)
        .toString()
        .padLeft(2, '0');
    return '₦$whole.$decimal';
  }

  String get formattedDebit => '-₦$amountWhole.$amountDecimal';

  ServiceState copyWith({
    ServiceConfig? config,
    String? recipient,
    String? selectedProvider,
    String? selectedProviderId,
    List<ServiceProviderModel>? providers,
    bool? isProvidersLoading,
    List<ServiceProductModel>? products,
    bool? isProductsLoading,
    int? amountKobo,
    int? availableBalanceKobo,
    String? pin,
    ServiceStage? stage,
    int? selectedPlanIndex,
    bool? isBeneficiaryListVisible,
    String? phoneNumber,
    ServiceNetwork? network,
    List<Beneficiary>? beneficiaries,
    List<UtilityBeneficiary>? utilityBeneficiaries,
    int? utilityBeneficiariesPage,
    bool? hasReachedMaxUtilityBeneficiaries,
    bool? isFetchingMoreUtilityBeneficiaries,
    List<ContactBeneficiary>? contactBeneficiaries,
    int? contactBeneficiariesPage,
    bool? hasReachedMaxContactBeneficiaries,
    bool? isFetchingMoreContactBeneficiaries,
    bool? isProcessing,
    String? errorMessage,
    ServiceTransactionModel? transaction,
    String? bundleCode,
    String? meterType,
    String? verifiedCustomerName,
    int? minVendAmountKobo,
    String? contactName,
    bool clearContactName = false,
  }) {
    return ServiceState(
      config: config ?? this.config,
      recipient: recipient ?? this.recipient,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      selectedProviderId: selectedProviderId ?? this.selectedProviderId,
      providers: providers ?? this.providers,
      isProvidersLoading: isProvidersLoading ?? this.isProvidersLoading,
      products: products ?? this.products,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      amountKobo: amountKobo ?? this.amountKobo,
      availableBalanceKobo: availableBalanceKobo ?? this.availableBalanceKobo,
      pin: pin ?? this.pin,
      stage: stage ?? this.stage,
      selectedPlanIndex: selectedPlanIndex ?? this.selectedPlanIndex,
      isBeneficiaryListVisible:
          isBeneficiaryListVisible ?? this.isBeneficiaryListVisible,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      network: network ?? this.network,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      utilityBeneficiaries: utilityBeneficiaries ?? this.utilityBeneficiaries,
      utilityBeneficiariesPage:
          utilityBeneficiariesPage ?? this.utilityBeneficiariesPage,
      hasReachedMaxUtilityBeneficiaries:
          hasReachedMaxUtilityBeneficiaries ??
              this.hasReachedMaxUtilityBeneficiaries,
      isFetchingMoreUtilityBeneficiaries:
          isFetchingMoreUtilityBeneficiaries ??
              this.isFetchingMoreUtilityBeneficiaries,
      contactBeneficiaries: contactBeneficiaries ?? this.contactBeneficiaries,
      contactBeneficiariesPage:
          contactBeneficiariesPage ?? this.contactBeneficiariesPage,
      hasReachedMaxContactBeneficiaries:
          hasReachedMaxContactBeneficiaries ??
              this.hasReachedMaxContactBeneficiaries,
      isFetchingMoreContactBeneficiaries:
          isFetchingMoreContactBeneficiaries ??
              this.isFetchingMoreContactBeneficiaries,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      transaction: transaction ?? this.transaction,
      bundleCode: bundleCode ?? this.bundleCode,
      meterType: meterType ?? this.meterType,
      verifiedCustomerName: verifiedCustomerName ?? this.verifiedCustomerName,
      minVendAmountKobo: minVendAmountKobo ?? this.minVendAmountKobo,
      contactName: clearContactName ? null : (contactName ?? this.contactName),
    );
  }

  static String _formatWholeNumber(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[index]);
    }

    return value < 0 ? '-${buffer.toString()}' : buffer.toString();
  }
}
