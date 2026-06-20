part of 'cable_tv_bloc.dart';

enum CableTvStep { smartcard, packageSelect, confirmation }

enum CableTvEntryPath { fresh, renew, change }

class CableTvState {
  final CableTvStep step;
  final CableTvEntryPath entryPath;
  final String smartcardNumber;
  final String selectedProvider;
  final bool isVerifying;
  final CableTvCustomer? customer;
  final String? verifyError;
  final List<ServiceProductModel> packages;
  final int selectedPackageIndex;
  final int availableBalanceKobo;
  final List<CableTvSmartcard> recentSmartcards;
  final bool isProcessing;
  final bool isSuccess;
  final bool isProvidersLoading;
  final String errorMessage;
  final List<ServiceProviderModel> providers;
  final bool isProductsLoading;
  final ServiceTransactionModel? transaction;

  const CableTvState({
    required this.step,
    required this.entryPath,
    required this.smartcardNumber,
    required this.selectedProvider,
    required this.isVerifying,
    this.customer,
    this.verifyError,
    required this.packages,
    required this.selectedPackageIndex,
    required this.availableBalanceKobo,
    required this.recentSmartcards,
    required this.isProcessing,
    required this.isSuccess,
    required this.isProvidersLoading,
    this.errorMessage = '',
    this.providers = const [],
    this.isProductsLoading = false,
    this.transaction,
  });

  factory CableTvState.initial({
    List<CableTvSmartcard> recentSmartcards = const [],
    int availableBalanceKobo = 9455272,
  }) {
    const defaultProvider = 'DStv';
    return CableTvState(
      step: CableTvStep.smartcard,
      entryPath: CableTvEntryPath.fresh,
      smartcardNumber: '',
      selectedProvider: defaultProvider,
      isVerifying: false,
      customer: null,
      verifyError: null,
      packages: [],
      selectedPackageIndex: 0,
      availableBalanceKobo: availableBalanceKobo,
      recentSmartcards: recentSmartcards,
      isProcessing: false,
      isSuccess: false,
      isProvidersLoading: false,
      errorMessage: '',
      providers: [],
      isProductsLoading: false,
    );
  }

  ServiceProductModel? get selectedPackage =>
      packages.isNotEmpty && selectedPackageIndex < packages.length
      ? packages[selectedPackageIndex]
      : null;

  String get formattedAmount {
    final kobo = selectedPackage?.amountKobo ?? 0;
    final whole = _fmt(kobo ~/ 100);
    final dec = kobo.remainder(100).toString().padLeft(2, '0');
    return '₦$whole.$dec';
  }

  String get formattedBalance {
    final whole = _fmt(availableBalanceKobo ~/ 100);
    final dec = availableBalanceKobo.remainder(100).toString().padLeft(2, '0');
    return '₦$whole.$dec';
  }

  static String _fmt(int value) {
    final d = value.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) b.write(',');
      b.write(d[i]);
    }
    return b.toString();
  }

  CableTvState copyWith({
    CableTvStep? step,
    CableTvEntryPath? entryPath,
    String? smartcardNumber,
    String? selectedProvider,
    bool? isVerifying,
    CableTvCustomer? customer,
    String? verifyError,
    List<ServiceProductModel>? packages,
    int? selectedPackageIndex,
    int? availableBalanceKobo,
    List<CableTvSmartcard>? recentSmartcards,
    bool? isProcessing,
    bool? isSuccess,
    bool clearCustomer = false,
    bool clearVerifyError = false,
    bool isProvidersLoading = false,
    String? errorMessage = '',
    List<ServiceProviderModel> providers = const [],
    bool isProductsLoading = false,
    final ServiceTransactionModel? transaction,
  }) {
    return CableTvState(
      step: step ?? this.step,
      entryPath: entryPath ?? this.entryPath,
      smartcardNumber: smartcardNumber ?? this.smartcardNumber,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      isVerifying: isVerifying ?? this.isVerifying,
      customer: clearCustomer ? null : (customer ?? this.customer),
      verifyError: clearVerifyError ? null : (verifyError ?? this.verifyError),
      packages: packages ?? this.packages,
      selectedPackageIndex: selectedPackageIndex ?? this.selectedPackageIndex,
      availableBalanceKobo: availableBalanceKobo ?? this.availableBalanceKobo,
      recentSmartcards: recentSmartcards ?? this.recentSmartcards,
      isProcessing: isProcessing ?? this.isProcessing,
      isSuccess: isSuccess ?? this.isSuccess,
      isProvidersLoading: isProvidersLoading,
      providers: providers ?? this.providers,
      isProductsLoading: isProductsLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      transaction: transaction ?? this.transaction,
    );
  }
}
