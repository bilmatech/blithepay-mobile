import 'package:blithepay/features/services/data/models/cable_tv_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cable_tv_event.dart';
part 'cable_tv_state.dart';

class CableTvBloc extends Bloc<CableTvEvent, CableTvState> {
  CableTvBloc({
    List<CableTvSmartcard> recentSmartcards = const [],
    int availableBalanceKobo = 9455272,
  }) : super(CableTvState.initial(
          recentSmartcards: recentSmartcards,
          availableBalanceKobo: availableBalanceKobo,
        )) {
    on<CableTvSmartcardChanged>(_onSmartcardChanged);
    on<CableTvProviderSelected>(_onProviderSelected);
    on<CableTvVerifyRequested>(_onVerifyRequested);
    on<CableTvPackageSelected>(_onPackageSelected);
    on<CableTvContinueToConfirmation>(_onContinueToConfirmation);
    on<CableTvBack>(_onBack);
    on<CableTvBeneficiaryRenewSelected>(_onBeneficiaryRenewSelected);
    on<CableTvBeneficiaryChangeSelected>(_onBeneficiaryChangeSelected);
    on<CableTvPayRequested>(_onPayRequested);
    on<CableTvSuccessDismissed>(_onSuccessDismissed);
  }

  void _onSmartcardChanged(
    CableTvSmartcardChanged event,
    Emitter<CableTvState> emit,
  ) {
    emit(state.copyWith(
      smartcardNumber: event.value,
      clearCustomer: true,
      clearVerifyError: true,
    ));
  }

  void _onProviderSelected(
    CableTvProviderSelected event,
    Emitter<CableTvState> emit,
  ) {
    emit(state.copyWith(
      selectedProvider: event.provider,
      packages: kCableTvPackages[event.provider] ?? [],
      selectedPackageIndex: 0,
    ));
  }

  Future<void> _onVerifyRequested(
    CableTvVerifyRequested event,
    Emitter<CableTvState> emit,
  ) async {
    final digits = state.smartcardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 6) {
      emit(state.copyWith(verifyError: 'Enter a valid smartcard number'));
      return;
    }

    emit(state.copyWith(isVerifying: true, clearVerifyError: true));
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    emit(state.copyWith(
      isVerifying: false,
      customer: const CableTvCustomer(
        name: 'John Doe',
        currentPackage: 'Compact',
        status: 'Active',
        dueDate: '30 Dec 2025',
      ),
      step: CableTvStep.packageSelect,
      entryPath: CableTvEntryPath.fresh,
    ));
  }

  void _onPackageSelected(
    CableTvPackageSelected event,
    Emitter<CableTvState> emit,
  ) {
    emit(state.copyWith(selectedPackageIndex: event.index));
  }

  void _onContinueToConfirmation(
    CableTvContinueToConfirmation event,
    Emitter<CableTvState> emit,
  ) {
    emit(state.copyWith(step: CableTvStep.confirmation));
  }

  void _onBack(CableTvBack event, Emitter<CableTvState> emit) {
    switch (state.step) {
      case CableTvStep.packageSelect:
        emit(state.copyWith(step: CableTvStep.smartcard));
      case CableTvStep.confirmation:
        if (state.entryPath == CableTvEntryPath.renew) {
          emit(state.copyWith(
            step: CableTvStep.smartcard,
            clearCustomer: true,
          ));
        } else {
          emit(state.copyWith(step: CableTvStep.packageSelect));
        }
      case CableTvStep.smartcard:
        break;
    }
  }

  void _onBeneficiaryRenewSelected(
    CableTvBeneficiaryRenewSelected event,
    Emitter<CableTvState> emit,
  ) {
    final sc = event.smartcard;
    final pkgs = kCableTvPackages[sc.provider] ?? [];
    final pkgIdx = pkgs.indexWhere((p) => p.title == sc.packageName);

    emit(state.copyWith(
      smartcardNumber: sc.smartcardNumber,
      selectedProvider: sc.provider,
      packages: pkgs,
      selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
      customer: CableTvCustomer(
        name: sc.customerName,
        currentPackage: sc.packageName,
        status: 'Active',
        dueDate: '30 Dec 2025',
      ),
      entryPath: CableTvEntryPath.renew,
      step: CableTvStep.confirmation,
    ));
  }

  void _onBeneficiaryChangeSelected(
    CableTvBeneficiaryChangeSelected event,
    Emitter<CableTvState> emit,
  ) {
    final sc = event.smartcard;
    final pkgs = kCableTvPackages[sc.provider] ?? [];
    final pkgIdx = pkgs.indexWhere((p) => p.title == sc.packageName);

    emit(state.copyWith(
      smartcardNumber: sc.smartcardNumber,
      selectedProvider: sc.provider,
      packages: pkgs,
      selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
      customer: CableTvCustomer(
        name: sc.customerName,
        currentPackage: sc.packageName,
        status: 'Active',
        dueDate: '30 Dec 2025',
      ),
      entryPath: CableTvEntryPath.change,
      step: CableTvStep.packageSelect,
    ));
  }

  Future<void> _onPayRequested(
    CableTvPayRequested event,
    Emitter<CableTvState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    emit(state.copyWith(isProcessing: false, isSuccess: true));
  }

  void _onSuccessDismissed(
    CableTvSuccessDismissed event,
    Emitter<CableTvState> emit,
  ) {
    emit(CableTvState.initial(
      recentSmartcards: state.recentSmartcards,
      availableBalanceKobo: state.availableBalanceKobo,
    ));
  }
}
