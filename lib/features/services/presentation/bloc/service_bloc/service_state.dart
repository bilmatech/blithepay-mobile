part of 'service_bloc.dart';

enum ServiceStage { entry, review, pin, success }

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
  final String priceLabel;

  const ServicePlan({
    required this.title,
    required this.description,
    required this.amountKobo,
    required this.priceLabel,
  });
}

class ServiceState {
  final ServiceConfig config;
  final String recipient;
  final String selectedProvider;
  final int amountKobo;
  final int availableBalanceKobo;
  final String pin;
  final ServiceStage stage;
  final int? selectedPlanIndex;
  final bool isBeneficiaryListVisible;
  final String phoneNumber;
  final ServiceNetwork? network;
  final List<Beneficiary> beneficiaries;
  final bool isProcessing;
  final String? errorMessage;

  const ServiceState({
    required this.config,
    required this.recipient,
    required this.selectedProvider,
    required this.amountKobo,
    required this.availableBalanceKobo,
    required this.pin,
    required this.stage,
    required this.selectedPlanIndex,
    required this.isBeneficiaryListVisible,
    required this.phoneNumber,
    required this.network,
    required this.beneficiaries,
    this.isProcessing = false,
    this.errorMessage = '',
  });

  factory ServiceState.initial(ServiceConfig config) {
    final hasPlans = config.plans.isNotEmpty;
    return ServiceState(
      config: config,
      recipient: '',
      selectedProvider: config.providerOptions.first,
      amountKobo: hasPlans ? config.plans.first.amountKobo : 0,
      availableBalanceKobo: config.availableBalanceKobo,
      pin: '',
      stage: ServiceStage.entry,
      selectedPlanIndex: hasPlans ? 0 : null,
      isBeneficiaryListVisible: false,
      phoneNumber: '',
      network: null,
      beneficiaries: const [],
      isProcessing: false,
      errorMessage: null,
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
    int? amountKobo,
    int? availableBalanceKobo,
    String? pin,
    ServiceStage? stage,
    int? selectedPlanIndex,
    bool? isBeneficiaryListVisible,
    String? phoneNumber,
    ServiceNetwork? network,
    List<Beneficiary>? beneficiaries,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return ServiceState(
      config: config ?? this.config,
      recipient: recipient ?? this.recipient,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      amountKobo: amountKobo ?? this.amountKobo,
      availableBalanceKobo: availableBalanceKobo ?? this.availableBalanceKobo,
      pin: pin ?? this.pin,
      stage: stage ?? this.stage,
      selectedPlanIndex: selectedPlanIndex ?? this.selectedPlanIndex,
      isBeneficiaryListVisible:
          isBeneficiaryListVisible ?? this.isBeneficiaryListVisible,
      phoneNumber: phoneNumber ?? this.recipient,
      network:
          network ??
          (this.config.providerOptions.contains(selectedProvider)
              ? ServiceNetwork.values.firstWhere(
                  (net) =>
                      net.toString().split('.').last ==
                      selectedProvider?.toLowerCase(),
                  orElse: () => ServiceNetwork.mtn,
                )
              : null),
      beneficiaries: beneficiaries ?? this.beneficiaries,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
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
