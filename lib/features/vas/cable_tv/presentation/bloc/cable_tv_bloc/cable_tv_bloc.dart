import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/vas/cable_tv/data/models/cable_tv_models.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:blithepay/features/vas/core/data/models/cable_tv_beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
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
    on<CableTvBalanceUpdated>(_onBalanceUpdated);
    on<CableTvBeneficiariesRequested>(_onBeneficiariesRequested);
    on<CableTvBeneficiarySelected>(_onBeneficiarySelected);
    on<CableTvAmountSelected>((event, emit) {
      emit(state.copyWith(amountKobo: event.amountKobo));
    });
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
          errorMessage: extractError(error),
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
    emit(state.copyWith(
      selectedProvider: event.provider,
      selectedProviderId: event.providerId,
      clearCustomer: true,
      clearVerifyError: true,
      selectedPackageIndex: 0,
      amountKobo: 0,
      packages: [],
    ));
    add(CableTvProductsRequested(event.providerId));
  }

  // ── Step 2 Flow: Fetch specific plan/package bouquet products ────────
  Future<void> _onProductsRequested(
    CableTvProductsRequested event,
    Emitter<CableTvState> emit,
  ) async {
    emit(state.copyWith(isProductsLoading: true, errorMessage: null));
    try {
      final products = await _serviceRepository.getCableProviderProducts(
        event.providerId,
      );
      emit(
        state.copyWith(
          isProductsLoading: false,
          packages: products,
          selectedPackageIndex: 0,
          amountKobo: products.isNotEmpty ? products[0].amountKobo.toInt() : 0,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isProductsLoading: false,
          errorMessage: extractError(error),
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

    // robust multi-layered extraction matching name or id criteria safely
    dynamic matchedProvider;
    try {
      matchedProvider = state.providers.firstWhere(
        (p) =>
            p.name == state.selectedProvider || p.id == state.selectedProvider,
      );
    } catch (_) {
      matchedProvider = null;
    }

    final String providerId = matchedProvider != null
        ? matchedProvider.id
        : state.selectedProvider;

    emit(
      state.copyWith(
        isVerifying: true,
        clearVerifyError: true,
        providers: state.providers, // Maintain array cache stability
      ),
    );

    try {
      final Map<String, dynamic> responseData = await _serviceRepository
          .verifySmartCard(
            smartcardNumber: state.smartcardNumber.replaceAll(RegExp(r'\s+'), ''),
            provider:
                providerId, // Securely hands over the correct API parameter
          );

      if (responseData['success'] == false ||
          responseData['status'] == 'failed') {
        final backendError =
            responseData['message'] ?? 'Smartcard verification failed.';
        throw Exception(backendError);
      }

      final dynamic dataObject = responseData['data'] ?? responseData;
      final String customerName =
          dataObject['customerName'] ??
          dataObject['name'] ??
          dataObject['customer_name'] ??
          'Valid Account';

      final String currentPackage =
          dataObject['currentPackage'] ?? dataObject['package'] ?? 'Unknown';

      emit(
        state.copyWith(
          isVerifying: false,
          providers: state.providers, // Maintain array cache stability
          customer: CableTvCustomer(
            name: customerName,
            currentPackage: currentPackage,
            status: dataObject['status'] ?? 'Active',
            dueDate: dataObject['dueDate'] ?? dataObject['due_date'] ?? '--',
          ),
          entryPath: CableTvEntryPath.fresh,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isVerifying: false,
          providers: state.providers, // Maintain array cache stability
          verifyError: extractError(error),
        ),
      );
    }
  }

  void _onPackageSelected(
    CableTvPackageSelected event,
    Emitter<CableTvState> emit,
  ) {
    final package = event.index >= 0 && event.index < state.packages.length
        ? state.packages[event.index]
        : null;
    emit(state.copyWith(
      selectedPackageIndex: event.index,
      amountKobo: package?.amountKobo.toInt() ?? 0,
    ));
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
    dynamic matchedProvider;
    try {
      matchedProvider = state.providers.firstWhere(
        (p) =>
            p.name.toLowerCase() == sc.provider.toLowerCase() ||
            p.id.toLowerCase() == sc.provider.toLowerCase(),
      );
    } catch (_) {
      matchedProvider = null;
    }
    final String providerId = matchedProvider != null
        ? matchedProvider.id
        : sc.provider;

    final pkgIdx = state.packages.indexWhere((p) => p.name == sc.packageName);
    final package = pkgIdx >= 0 && pkgIdx < state.packages.length ? state.packages[pkgIdx] : null;

    emit(
      state.copyWith(
        smartcardNumber: sc.smartcardNumber,
        selectedProvider: matchedProvider != null ? matchedProvider.name : sc.provider,
        selectedProviderId: providerId,
        selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
        amountKobo: package?.amountKobo.toInt() ?? 0,
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

    add(CableTvProductsRequested(providerId));
  }

  void _onBeneficiaryChangeSelected(
    CableTvBeneficiaryChangeSelected event,
    Emitter<CableTvState> emit,
  ) {
    final sc = event.smartcard;
    dynamic matchedProvider;
    try {
      matchedProvider = state.providers.firstWhere(
        (p) =>
            p.name.toLowerCase() == sc.provider.toLowerCase() ||
            p.id.toLowerCase() == sc.provider.toLowerCase(),
      );
    } catch (_) {
      matchedProvider = null;
    }
    final String providerId = matchedProvider != null
        ? matchedProvider.id
        : sc.provider;

    final pkgIdx = state.packages.indexWhere((p) => p.name == sc.packageName);
    final package = pkgIdx >= 0 && pkgIdx < state.packages.length ? state.packages[pkgIdx] : null;

    emit(
      state.copyWith(
        smartcardNumber: sc.smartcardNumber,
        selectedProvider: matchedProvider != null ? matchedProvider.name : sc.provider,
        selectedProviderId: providerId,
        selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
        amountKobo: package?.amountKobo.toInt() ?? 0,
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

    add(CableTvProductsRequested(providerId));
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
        provider: state.selectedProviderId.isNotEmpty ? state.selectedProviderId : state.selectedProvider,
        smartcardNumber: state.smartcardNumber.replaceAll(RegExp(r'\s+'), ''),
        amountKobo: state.amountKobo,
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
      emit(
        state.copyWith(isProcessing: false, verifyError: extractError(error)),
      );
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
      ).copyWith(
        providers: state.providers,
        beneficiaries: state.beneficiaries,
        beneficiariesPage: state.beneficiariesPage,
        hasReachedMaxBeneficiaries: state.hasReachedMaxBeneficiaries,
      ),
    );
  }

  void _onBalanceUpdated(
    CableTvBalanceUpdated event,
    Emitter<CableTvState> emit,
  ) {
    emit(state.copyWith(availableBalanceKobo: event.balanceKobo));
  }

  Future<void> _onBeneficiariesRequested(
    CableTvBeneficiariesRequested event,
    Emitter<CableTvState> emit,
  ) async {
    if (state.hasReachedMaxBeneficiaries) return;
    if (state.isFetchingMoreBeneficiaries) return;

    final isInitial = state.beneficiaries.isEmpty;
    final nextPage = isInitial ? 1 : state.beneficiariesPage + 1;

    try {
      if (isInitial) {
        emit(state.copyWith(isProvidersLoading: true));
      } else {
        emit(state.copyWith(isFetchingMoreBeneficiaries: true));
      }

      final list = await _serviceRepository.getCableTvBeneficiaries(
        page: nextPage,
        limit: 10,
      );

      final hasReachedMax = list.length < 10;
      final updatedList = List<CableTvBeneficiary>.from(state.beneficiaries)
        ..addAll(list);

      emit(
        state.copyWith(
          beneficiaries: updatedList,
          beneficiariesPage: nextPage,
          hasReachedMaxBeneficiaries: hasReachedMax,
          isFetchingMoreBeneficiaries: false,
          isProvidersLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isFetchingMoreBeneficiaries: false,
          isProvidersLoading: false,
        ),
      );
    }
  }

  void _onBeneficiarySelected(
    CableTvBeneficiarySelected event,
    Emitter<CableTvState> emit,
  ) {
    final beneficiary = event.beneficiary;
    String providerName = '';
    try {
      final p = state.providers.firstWhere((prov) => prov.id == beneficiary.serviceCategoryId);
      providerName = p.name;
    } catch (_) {}

    emit(
      state.copyWith(
        smartcardNumber: beneficiary.smartcardNumber,
        selectedProvider: providerName,
        selectedProviderId: beneficiary.serviceCategoryId,
        customer: CableTvCustomer(
          name: beneficiary.customerName,
          currentPackage: beneficiary.bundleCode ?? 'Unknown',
          status: 'Active',
          dueDate: 'N/A',
        ),
        clearVerifyError: true,
        selectedPackageIndex: 0,
        amountKobo: 0,
        packages: [],
      ),
    );

    add(CableTvProductsRequested(beneficiary.serviceCategoryId));
  }
}
// class CableTvBloc extends Bloc<CableTvEvent, CableTvState> {
//   final ServiceRepository _serviceRepository;
//   final String? _serviceId;

//   CableTvBloc({
//     required ServiceRepository serviceRepository,
//     String? serviceId,
//     List<CableTvSmartcard> recentSmartcards = const [],
//     int availableBalanceKobo = 9455272,
//   }) : _serviceRepository = serviceRepository,
//        _serviceId = serviceId,
//        super(
//          CableTvState.initial(
//            recentSmartcards: recentSmartcards,
//            availableBalanceKobo: availableBalanceKobo,
//          ),
//        ) {
//     // Core Lifecycle Event
//     on<CableTvInitRequested>(_onInitRequested);

//     // Step 1 Flow Inputs
//     on<CableTvSmartcardChanged>(_onSmartcardChanged);
//     on<CableTvProviderSelected>(_onProviderSelected);
//     on<CableTvProductsRequested>(_onProductsRequested);
//     on<CableTvVerifyRequested>(_onVerifyRequested);

//     // Step 2 & 3 Selection Flows
//     on<CableTvPackageSelected>(_onPackageSelected);
//     on<CableTvContinueToConfirmation>(_onContinueToConfirmation);
//     on<CableTvBack>(_onBack);

//     // Beneficiary Profiles Handling
//     on<CableTvBeneficiaryRenewSelected>(_onBeneficiaryRenewSelected);
//     on<CableTvBeneficiaryChangeSelected>(_onBeneficiaryChangeSelected);

//     // Payment Process Actions
//     on<CableTvPayRequested>(_onPayRequested);
//     on<CableTvSuccessDismissed>(_onSuccessDismissed);
//   }

//   // ── Initial Setup Action: Fetch available providers instantly ─────────
//   Future<void> _onInitRequested(
//     CableTvInitRequested event,
//     Emitter<CableTvState> emit,
//   ) async {
//     if (_serviceId == null) return;
//     emit(state.copyWith(isProvidersLoading: true, errorMessage: null));
//     try {
//       final providers = await _serviceRepository.getCableProviders(_serviceId);
//       print(
//         'Fetched providers: ${providers.map((p) => p.name).toList()}',
//       ); // Debugging log
//       emit(
//         state.copyWith(
//           isProvidersLoading: false,
//           providers: providers,
//           errorMessage: null,
//         ),
//       );
//     } catch (error) {
//       emit(
//         state.copyWith(
//           isProvidersLoading: false,
//           errorMessage: error.toString(),
//         ),
//       );
//     }
//   }

//   void _onSmartcardChanged(
//     CableTvSmartcardChanged event,
//     Emitter<CableTvState> emit,
//   ) {
//     emit(
//       state.copyWith(
//         smartcardNumber: event.value,
//         clearCustomer: true,
//         clearVerifyError: true,
//       ),
//     );
//   }

//   void _onProviderSelected(
//     CableTvProviderSelected event,
//     Emitter<CableTvState> emit,
//   ) {
//     // Declare as dynamic or nullable model variable
//     dynamic matchedProvider;

//     try {
//       matchedProvider = state.providers.firstWhere(
//         (p) => p.name == event.provider,
//       );
//     } catch (_) {
//       matchedProvider =
//           null; // Safely catches if no match is found without breaking compilation
//     }

//     // Fall back to the raw name string if no matching model is found
//     final String targetIdForApi = matchedProvider != null
//         ? matchedProvider.id
//         : event.provider;

//     // Update state using the name so your UI highlights match
//     emit(state.copyWith(selectedProvider: event.provider, clearCustomer: true));

//     // Request products with the correct backend API ID
//     add(CableTvProductsRequested(targetIdForApi));
//   }

//   // ── Step 2 Flow: Fetch specific plan/package bouquet products ────────
//   Future<void> _onProductsRequested(
//     CableTvProductsRequested event,
//     Emitter<CableTvState> emit, // FIX: Changed from Emitter<ServiceState>
//   ) async {
//     emit(state.copyWith(isProductsLoading: true, errorMessage: null));
//     try {
//       final products = await _serviceRepository.getCableProviderProducts(
//         event.providerId,
//       );
//       emit(
//         state.copyWith(
//           isProductsLoading: false,
//           // Assuming your state maps products into `packages` or a matching List field
//           packages: products,
//           selectedPackageIndex: 0,
//           errorMessage: null,
//         ),
//       );
//     } catch (error) {
//       emit(
//         state.copyWith(
//           isProductsLoading: false,
//           errorMessage: error.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> _onVerifyRequested(
//     CableTvVerifyRequested event,
//     Emitter<CableTvState> emit,
//   ) async {
//     final digits = state.smartcardNumber.replaceAll(RegExp(r'[^\d]'), '');
//     if (digits.length < 6) {
//       emit(state.copyWith(verifyError: 'Enter a valid smartcard number'));
//       return;
//     }

//     emit(state.copyWith(isVerifying: true, clearVerifyError: true));
//     try {
//       // Replace with your real verification endpoint if applicable
//       await Future<void>.delayed(const Duration(milliseconds: 1500));

//       emit(
//         state.copyWith(
//           isVerifying: false,
//           customer: const CableTvCustomer(
//             name: 'John Doe',
//             currentPackage: 'Compact',
//             status: 'Active',
//             dueDate: '30 Dec 2026',
//           ),
//           step: CableTvStep.packageSelect,
//           entryPath: CableTvEntryPath.fresh,
//         ),
//       );
//     } catch (error) {
//       emit(state.copyWith(isVerifying: false, verifyError: error.toString()));
//     }
//   }

//   void _onPackageSelected(
//     CableTvPackageSelected event,
//     Emitter<CableTvState> emit,
//   ) {
//     // FIX: Removed the copy-pasted provider network loader loop from here
//     emit(state.copyWith(selectedPackageIndex: event.index));
//   }

//   void _onContinueToConfirmation(
//     CableTvContinueToConfirmation event,
//     Emitter<CableTvState> emit,
//   ) {
//     emit(state.copyWith(step: CableTvStep.confirmation));
//   }

//   void _onBack(CableTvBack event, Emitter<CableTvState> emit) {
//     switch (state.step) {
//       case CableTvStep.packageSelect:
//         emit(state.copyWith(step: CableTvStep.smartcard));
//       case CableTvStep.confirmation:
//         if (state.entryPath == CableTvEntryPath.renew) {
//           emit(
//             state.copyWith(step: CableTvStep.smartcard, clearCustomer: true),
//           );
//         } else {
//           emit(state.copyWith(step: CableTvStep.packageSelect));
//         }
//       case CableTvStep.smartcard:
//         break;
//     }
//   }

//   void _onBeneficiaryRenewSelected(
//     CableTvBeneficiaryRenewSelected event,
//     Emitter<CableTvState> emit,
//   ) {
//     final sc = event.smartcard;
//     final pkgIdx = state.packages.indexWhere((p) => p.name == sc.packageName);

//     emit(
//       state.copyWith(
//         smartcardNumber: sc.smartcardNumber,
//         selectedProvider: sc.provider,
//         selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
//         customer: CableTvCustomer(
//           name: sc.customerName,
//           currentPackage: sc.packageName,
//           status: 'Active',
//           dueDate: '30 Dec 2026',
//         ),
//         entryPath: CableTvEntryPath.renew,
//         step: CableTvStep.confirmation,
//       ),
//     );
//   }

//   void _onBeneficiaryChangeSelected(
//     CableTvBeneficiaryChangeSelected event,
//     Emitter<CableTvState> emit,
//   ) {
//     final sc = event.smartcard;
//     final pkgIdx = state.packages.indexWhere((p) => p.name == sc.packageName);

//     emit(
//       state.copyWith(
//         smartcardNumber: sc.smartcardNumber,
//         selectedProvider: sc.provider,
//         selectedPackageIndex: pkgIdx < 0 ? 0 : pkgIdx,
//         customer: CableTvCustomer(
//           name: sc.customerName,
//           currentPackage: sc.packageName,
//           status: 'Active',
//           dueDate: '30 Dec 2026',
//         ),
//         entryPath: CableTvEntryPath.change,
//         step: CableTvStep.packageSelect,
//       ),
//     );
//   }

//   Future<void> _onPayRequested(
//     CableTvPayRequested event,
//     Emitter<CableTvState> emit,
//   ) async {
//     emit(state.copyWith(isProcessing: true, clearVerifyError: true));
//     try {
//       final package = state.selectedPackage;
//       if (package == null) {
//         throw Exception('Package selection is required');
//       }
//       final token = await _serviceRepository.verifyPin(event.pin);

//       final transaction = await _serviceRepository.subscribeCableTv(
//         provider: state.selectedProvider,
//         smartcardNumber: state.smartcardNumber,
//         // packageName: package.name,
//         amountKobo: package.amountKobo.toInt() * 100, // Sync mapping type
//         pin: event.pin,
//         bundleCode: package.bundleCode,
//         challengeToken: token,
//       );

//       emit(
//         state.copyWith(
//           isProcessing: false,
//           isSuccess: true,
//           transaction: transaction,
//         ),
//       );
//     } catch (error) {
//       emit(state.copyWith(isProcessing: false, verifyError: error.toString()));
//     }
//   }

//   void _onSuccessDismissed(
//     CableTvSuccessDismissed event,
//     Emitter<CableTvState> emit,
//   ) {
//     emit(
//       CableTvState.initial(
//         recentSmartcards: state.recentSmartcards,
//         availableBalanceKobo: state.availableBalanceKobo,
//       ),
//     );
//   }
// }
