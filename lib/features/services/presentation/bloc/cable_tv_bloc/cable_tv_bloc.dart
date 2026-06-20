import 'package:blithepay/features/services/data/models/cable_tv_models.dart';
import 'package:blithepay/features/services/data/models/service_model.dart';
import 'package:blithepay/features/services/data/models/service_purchase_response.dart';
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cable_tv_event.dart';
part 'cable_tv_state.dart';

class CableTvBloc extends Bloc<CableTvEvent, CableTvState> {
  final ServiceRepository _serviceRepository;
  final String? _serviceId;

  CableTvBloc({
    required ServiceRepository serviceRepository,
    String? serviceId,
    List<CableTvSmartcard> recentSmartcards = const [],
    int availableBalanceKobo = 9455272,
  }) : _serviceRepository = serviceRepository,
       _serviceId = serviceId,
       super(
         CableTvState.initial(
           recentSmartcards: recentSmartcards,
           availableBalanceKobo: availableBalanceKobo,
         ),
       ) {
    // Core Lifecycle Event
    on<CableTvInitRequested>(_onInitRequested);

    // Step 1 Flow Inputs
    on<CableTvSmartcardChanged>(_onSmartcardChanged);
    on<CableTvProviderSelected>(_onProviderSelected);
    on<CableTvProductsRequested>(_onProductsRequested);
    on<CableTvVerifyRequested>(_onVerifyRequested);

    // Step 2 & 3 Selection Flows
    on<CableTvPackageSelected>(_onPackageSelected);
    on<CableTvContinueToConfirmation>(_onContinueToConfirmation);
    on<CableTvBack>(_onBack);

    // Beneficiary Profiles Handling
    on<CableTvBeneficiaryRenewSelected>(_onBeneficiaryRenewSelected);
    on<CableTvBeneficiaryChangeSelected>(_onBeneficiaryChangeSelected);

    // Payment Process Actions
    on<CableTvPayRequested>(_onPayRequested);
    on<CableTvSuccessDismissed>(_onSuccessDismissed);
  }

  // ── Initial Setup Action: Fetch available providers instantly ─────────
  Future<void> _onInitRequested(
    CableTvInitRequested event,
    Emitter<CableTvState> emit,
  ) async {
    if (_serviceId == null) return;
    emit(state.copyWith(isProvidersLoading: true, errorMessage: null));
    try {
      final providers = await _serviceRepository.getCableProviders(_serviceId);
      print(
        'Fetched providers: ${providers.map((p) => p.name).toList()}',
      ); // Debugging log
      emit(
        state.copyWith(
          isProvidersLoading: false,
          providers: providers,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isProvidersLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onSmartcardChanged(
    CableTvSmartcardChanged event,
    Emitter<CableTvState> emit,
  ) {
    emit(
      state.copyWith(
        smartcardNumber: event.value,
        clearCustomer: true,
        clearVerifyError: true,
      ),
    );
  }

  void _onProviderSelected(
    CableTvProviderSelected event,
    Emitter<CableTvState> emit,
  ) {
    emit(state.copyWith(selectedProvider: event.provider, clearCustomer: true));
    add(CableTvProductsRequested(event.provider));
    }

  // ── Step 2 Flow: Fetch specific plan/package bouquet products ────────
  Future<void> _onProductsRequested(
    CableTvProductsRequested event,
    Emitter<CableTvState> emit, // FIX: Changed from Emitter<ServiceState>
  ) async {
    emit(state.copyWith(isProductsLoading: true, errorMessage: null));
    try {
      final products = await _serviceRepository.getCableProviderProducts(
        event.providerId,
      );
      emit(
        state.copyWith(
          isProductsLoading: false,
          // Assuming your state maps products into `packages` or a matching List field
          packages: products,
          selectedPackageIndex: 0,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isProductsLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
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
    try {
      // Replace with your real verification endpoint if applicable
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      emit(
        state.copyWith(
          isVerifying: false,
          customer: const CableTvCustomer(
            name: 'John Doe',
            currentPackage: 'Compact',
            status: 'Active',
            dueDate: '30 Dec 2026',
          ),
          step: CableTvStep.packageSelect,
          entryPath: CableTvEntryPath.fresh,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isVerifying: false, verifyError: error.toString()));
    }
  }

  void _onPackageSelected(
    CableTvPackageSelected event,
    Emitter<CableTvState> emit,
  ) {
    // FIX: Removed the copy-pasted provider network loader loop from here
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
          emit(
            state.copyWith(step: CableTvStep.smartcard, clearCustomer: true),
          );
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
    final pkgIdx = state.packages.indexWhere((p) => p.name == sc.packageName);

    emit(
      state.copyWith(
        smartcardNumber: sc.smartcardNumber,
        selectedProvider: sc.provider,
        selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
        customer: CableTvCustomer(
          name: sc.customerName,
          currentPackage: sc.packageName,
          status: 'Active',
          dueDate: '30 Dec 2026',
        ),
        entryPath: CableTvEntryPath.renew,
        step: CableTvStep.confirmation,
      ),
    );
  }

  void _onBeneficiaryChangeSelected(
    CableTvBeneficiaryChangeSelected event,
    Emitter<CableTvState> emit,
  ) {
    final sc = event.smartcard;
    final pkgIdx = state.packages.indexWhere((p) => p.name == sc.packageName);

    emit(
      state.copyWith(
        smartcardNumber: sc.smartcardNumber,
        selectedProvider: sc.provider,
        selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
        customer: CableTvCustomer(
          name: sc.customerName,
          currentPackage: sc.packageName,
          status: 'Active',
          dueDate: '30 Dec 2026',
        ),
        entryPath: CableTvEntryPath.change,
        step: CableTvStep.packageSelect,
      ),
    );
  }

  Future<void> _onPayRequested(
    CableTvPayRequested event,
    Emitter<CableTvState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearVerifyError: true));
    try {
      final package = state.selectedPackage;
      if (package == null) {
        throw Exception('Package selection is required');
      }
      final token = await _serviceRepository.verifyPin(event.pin);

      final transaction = await _serviceRepository.subscribeCableTv(
        provider: state.selectedProvider,
        smartcardNumber: state.smartcardNumber,
        // packageName: package.name,
        amountKobo: package.amountKobo.toInt() * 100, // Sync mapping type
        pin: event.pin,
        bundleCode: package.bundleCode,
        challengeToken: token,
      );

      emit(
        state.copyWith(
          isProcessing: false,
          isSuccess: true,
           transaction: transaction,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isProcessing: false, verifyError: error.toString()));
    }
  }

  void _onSuccessDismissed(
    CableTvSuccessDismissed event,
    Emitter<CableTvState> emit,
  ) {
    emit(
      CableTvState.initial(
        recentSmartcards: state.recentSmartcards,
        availableBalanceKobo: state.availableBalanceKobo,
      ),
    );
  }
}
