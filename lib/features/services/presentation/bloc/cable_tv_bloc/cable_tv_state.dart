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
  final List<CableTvPackage> packages;
  final int selectedPackageIndex;
  final int availableBalanceKobo;
  final List<CableTvSmartcard> recentSmartcards;
  final bool isProcessing;
  final bool isSuccess;

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
      packages: kCableTvPackages[defaultProvider] ?? [],
      selectedPackageIndex: 0,
      availableBalanceKobo: availableBalanceKobo,
      recentSmartcards: recentSmartcards,
      isProcessing: false,
      isSuccess: false,
    );
  }

  CableTvPackage? get selectedPackage =>
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
    List<CableTvPackage>? packages,
    int? selectedPackageIndex,
    int? availableBalanceKobo,
    List<CableTvSmartcard>? recentSmartcards,
    bool? isProcessing,
    bool? isSuccess,
    bool clearCustomer = false,
    bool clearVerifyError = false,
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
    );
  }
}
