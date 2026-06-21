import 'dart:async';

import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/vas/core/data/models/beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:blithepay/features/vas/core/data/models/service_purchase_response.dart';
import 'package:blithepay/features/vas/core/data/models/utility_beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/models/contact_beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/repositories/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository _serviceRepository;
  final String? serviceId;

  String? get currentServiceId => serviceId;

  ServiceBloc({
    required ServiceRepository serviceRepository,
    required ServiceConfig config,
    List<Beneficiary> initialBeneficiaries = const [],
    this.serviceId,
  }) : _serviceRepository = serviceRepository,
       super(
         ServiceState.initial(
           config,
           initialBeneficiaries: initialBeneficiaries,
         ),
       ) {
    on<ServiceRecipientChanged>(_onRecipientChanged);
    on<ServiceProviderSelected>(_onProviderSelected);
    on<ServiceProvidersRequested>(_onProvidersRequested);
    on<ServiceProductsRequested>(_onProductsRequested);
    on<ServiceBeneficiaryListToggled>(_onBeneficiaryListToggled);
    on<ServiceBeneficiarySelected>(_onBeneficiarySelected);
    on<ServiceNetworkDetected>(_onNetworkDetected);
    on<ServicePlanSelected>(_onPlanSelected);
    on<ServiceAmountSelected>(_onAmountSelected);
    //  on<ServiceReviewRequested>(_onReviewRequested);
    on<ServiceReviewClosed>(_onReviewClosed);
    on<ServicePinRequested>(_onPinRequested);
    on<ServicePinDigitPressed>(_onPinDigitPressed);
    on<ServicePinBackspacePressed>(_onPinBackspacePressed);
    on<ServiceSuccessDismissed>(_onSuccessDismissed);
    on<ServiceBeneficiaryRemoved>(_onBeneficiaryRemoved);
    on<ServiceBeneficiariesCleared>(_onBeneficiariesCleared);
    on<ServicePinSubmitted>(_onServicePinSubmitted);
    on<ServiceResetRequested>(_onServiceResetRequested);

    on<ServiceVerifyMeterRequested>(_onVerifyMeterRequested);
    on<ServiceInitRequested>(_onInitRequested);
    on<ServiceBalanceUpdated>(_onBalanceUpdated);
    on<ServiceUtilityBeneficiariesRequested>(_onUtilityBeneficiariesRequested);
    on<ServiceUtilityBeneficiarySelected>(_onUtilityBeneficiarySelected);
    on<ServiceContactBeneficiariesRequested>(_onContactBeneficiariesRequested);
    on<ServiceContactBeneficiarySelected>(_onContactBeneficiarySelected);

    if (serviceId != null && serviceId!.isNotEmpty) {
      add(ServiceProvidersRequested(serviceId!));
    }
    final title = config.title.toLowerCase().trim();
    if (title == 'airtime' || title == 'data' || title == 'internet') {
      add(ServiceContactBeneficiariesRequested());
    }
  }

  void _onRecipientChanged(
    ServiceRecipientChanged event,
    Emitter<ServiceState> emit,
  ) {
    final isElectricity =
        state.config.title.toLowerCase().trim() == 'electricity' ||
        state.config.title.toLowerCase().trim() == 'utility';

    emit(
      state.copyWith(
        recipient: event.recipient,
        phoneNumber: event.recipient,
        selectedPlanIndex: null,
        verifiedCustomerName: isElectricity ? null : state.verifiedCustomerName,
        minVendAmountKobo: isElectricity ? null : state.minVendAmountKobo,
        contactName: event.contactName,
        clearContactName: event.contactName == null,
      ),
    );
  }

  void _onProviderSelected(
    ServiceProviderSelected event,
    Emitter<ServiceState> emit,
  ) {
    final isElectricity =
        state.config.title.toLowerCase().trim() == 'electricity';

    emit(
      state.copyWith(
        selectedProvider: event.provider,
        selectedProviderId: event.providerId ?? state.selectedProviderId,
        bundleCode: event.bundleCode,
        verifiedCustomerName: isElectricity ? null : state.verifiedCustomerName,
        minVendAmountKobo: isElectricity ? null : state.minVendAmountKobo,
        recipient: isElectricity ? '' : state.recipient,
      ),
    );

    final isAirtime =
        state.config.title.toLowerCase().trim() == 'airtime' ||
        state.config.title.toLowerCase().trim() == 'electricity';

    if (!isAirtime &&
        event.providerId != null &&
        event.providerId!.isNotEmpty) {
      add(ServiceProductsRequested(event.providerId!));
    }
  }

  Future<void> _onProvidersRequested(
    ServiceProvidersRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(state.copyWith(isProvidersLoading: true, errorMessage: null));
    try {
      final providers = await _serviceRepository.getServiceProviders(
        event.serviceId,
      );
      // final selectedProvider = providers.isNotEmpty
      //     ? providers.first.name
      //     : state.selectedProvider;
      // final selectedProviderId = providers.isNotEmpty
      //     ? providers.first.id
      //     : null;
      emit(
        state.copyWith(
          isProvidersLoading: false,
          providers: providers,
          selectedProvider: null,
          selectedProviderId: null,
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

  Future<void> _onProductsRequested(
    ServiceProductsRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(
      state.copyWith(
        isProductsLoading: true,
        errorMessage: null,

        // reset old selection
        selectedPlanIndex: null,
        bundleCode: null,
        amountKobo: 0,
      ),
    );

    try {
      final products = await _serviceRepository.getProviderProducts(
        event.providerId,
      );

      emit(
        state.copyWith(
          isProductsLoading: false,
          products: products,

          // ensure clean state
          selectedPlanIndex: null,
          bundleCode: null,
          amountKobo: 0,

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

  void _onPlanSelected(ServicePlanSelected event, Emitter<ServiceState> emit) {
    if (state.products.isNotEmpty && event.index < state.products.length) {
      final product = state.products[event.index];
      emit(
        state.copyWith(
          selectedPlanIndex: event.index,
          amountKobo: product.amountKobo,
        ),
      );
    } else if (event.index < state.config.plans.length) {
      final plan = state.config.plans[event.index];
      emit(
        state.copyWith(
          selectedPlanIndex: event.index,
          amountKobo: plan.amountKobo,
          bundleCode: plan.bundleCode,
          meterType: plan.title.toLowerCase(),
        ),
      );
    }
  }

  void _onAmountSelected(
    ServiceAmountSelected event,
    Emitter<ServiceState> emit,
  ) {
    emit(state.copyWith(amountKobo: event.amountKobo, selectedPlanIndex: null));
  }

  // void _onReviewRequested(
  //   ServiceReviewRequested event,
  //   Emitter<ServiceState> emit,
  // ) {
  //   emit(state.copyWith(stage: ServiceStage.review));
  // }
  void _onReviewClosed(ServiceReviewClosed event, Emitter<ServiceState> emit) {
    emit(state.copyWith(stage: ServiceStage.entry, pin: '', errorMessage: ''));
  }

  void _onPinRequested(ServicePinRequested event, Emitter<ServiceState> emit) {
    emit(state.copyWith(stage: ServiceStage.pin, pin: ''));
  }

  void _onPinDigitPressed(
    ServicePinDigitPressed event,
    Emitter<ServiceState> emit,
  ) {
    if (state.pin.length >= 4) {
      return;
    }

    final nextPin = '${state.pin}${event.digit}';
    emit(
      state.copyWith(
        pin: nextPin,
        stage: nextPin.length == 4 ? ServiceStage.success : ServiceStage.pin,
      ),
    );
  }

  void _onPinBackspacePressed(
    ServicePinBackspacePressed event,
    Emitter<ServiceState> emit,
  ) {
    if (state.pin.isEmpty) {
      return;
    }

    emit(state.copyWith(pin: state.pin.substring(0, state.pin.length - 1)));
  }

  void _onSuccessDismissed(
    ServiceSuccessDismissed event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(
        recipient: '',
        selectedProvider: null,
        selectedProviderId: null,
        products: [],
        selectedPlanIndex: null,
        amountKobo: 0,
        pin: '',
        stage: ServiceStage.entry,
        errorMessage: null,
        transaction: null,
        verifiedCustomerName: null,
        clearContactName: true,
      ),
    );
  }

  void _onBeneficiaryListToggled(
    ServiceBeneficiaryListToggled event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(isBeneficiaryListVisible: !state.isBeneficiaryListVisible),
    );
  }

  void _onNetworkDetected(
    ServiceNetworkDetected event,
    Emitter<ServiceState> emit,
  ) {
    // Bypass copyWith because null must clear the network, not fall back to prior value.
    emit(
      ServiceState(
        config: state.config,
        recipient: state.recipient,
        selectedProvider: state.selectedProvider,
        selectedProviderId: state.selectedProviderId,
        providers: state.providers,
        isProvidersLoading: state.isProvidersLoading,
        products: state.products,
        isProductsLoading: state.isProductsLoading,
        amountKobo: state.amountKobo,
        availableBalanceKobo: state.availableBalanceKobo,
        pin: state.pin,
        stage: state.stage,
        selectedPlanIndex: state.selectedPlanIndex,
        isBeneficiaryListVisible: state.isBeneficiaryListVisible,
        phoneNumber: state.phoneNumber,
        network: event.network,
        beneficiaries: state.beneficiaries,
        utilityBeneficiaries: state.utilityBeneficiaries,
        utilityBeneficiariesPage: state.utilityBeneficiariesPage,
        hasReachedMaxUtilityBeneficiaries: state.hasReachedMaxUtilityBeneficiaries,
        isFetchingMoreUtilityBeneficiaries: state.isFetchingMoreUtilityBeneficiaries,
        contactBeneficiaries: state.contactBeneficiaries,
        contactBeneficiariesPage: state.contactBeneficiariesPage,
        hasReachedMaxContactBeneficiaries: state.hasReachedMaxContactBeneficiaries,
        isFetchingMoreContactBeneficiaries: state.isFetchingMoreContactBeneficiaries,
        isProcessing: state.isProcessing,
        errorMessage: state.errorMessage,
        bundleCode: state.bundleCode,
        meterType: state.meterType,
        contactName: state.contactName,
      ),
    );
  }

  void _onBeneficiarySelected(
    ServiceBeneficiarySelected event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(
        phoneNumber: event.beneficiary.phoneNumber,
        network: event.beneficiary.network,
        isBeneficiaryListVisible: false,
      ),
    );
  }

  void _onBeneficiaryRemoved(
    ServiceBeneficiaryRemoved event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(
        beneficiaries: state.beneficiaries
            .where((beneficiary) => beneficiary.id != event.beneficiaryId)
            .toList(),
      ),
    );
  }

  void _onBeneficiariesCleared(
    ServiceBeneficiariesCleared event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(beneficiaries: const [], isBeneficiaryListVisible: false),
    );
  }

  Future<void> _onServicePinSubmitted(
    ServicePinSubmitted event,
    Emitter<ServiceState> emit,
  ) async {
    await _performServicePurchase(event.pin, emit);
  }

  Future<void> _performServicePurchase(
    String pin,
    Emitter<ServiceState> emit,
  ) async {
    final serviceId = this.serviceId;
    final providerId = state.selectedProviderId ?? state.selectedProvider;

    if (serviceId == null || serviceId.isEmpty) {
      throw Exception('Service ID is required for purchase');
    }

    try {
      emit(state.copyWith(isProcessing: true, errorMessage: null));

      final token = await _serviceRepository.verifyPin(pin);
      ServiceTransactionModel? transactionResult;

      final cleanRecipient = state.recipient.replaceAll(RegExp(r'\s+'), '');

      final title = state.config.title.toLowerCase().trim();
      switch (title) {
        case 'airtime':
          transactionResult = await _serviceRepository.purchaseAirtime(
            serviceId: serviceId,
            recipient: cleanRecipient,
            providerId: providerId,
            amountKobo: state.amountKobo,
            challengeToken: token,
            contactName: state.contactName,
          );
          break;
        case 'data':
        case 'internet':
          if (state.selectedPlanIndex == null ||
              state.selectedPlanIndex! >= state.products.length) {
            throw Exception('Select a bundle');
          }

          final selectedProduct = state.products[state.selectedPlanIndex!];

          debugPrint('BUYING -> ${selectedProduct.bundleCode}');

          transactionResult = await _serviceRepository.purchaseInternet(
            serviceId: serviceId,
            providerId: providerId,
            recipient: cleanRecipient,

            // use source of truth
            bundleCode: selectedProduct.bundleCode,

            amountKobo: selectedProduct.amountKobo,
            challengeToken: token,
            contactName: state.contactName,
          );

          break;
        case 'electricity':
        case 'utility':
          transactionResult = await _serviceRepository.purchaseUtility(
            serviceId: providerId.isNotEmpty ? providerId : serviceId,
            meterNumber: cleanRecipient,
            meterType: state.meterType,
            amountKobo: state.amountKobo,
            challengeToken: token,
          );
          break;
        default:
          throw Exception('Unsupported service type: ${state.config.title}');
      }

      emit(
        state.copyWith(
          isProcessing: false,
          stage: ServiceStage.success,
          transaction: transactionResult,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isProcessing: false,
          stage: ServiceStage.entry,
          errorMessage: extractError(error),
          transaction: null,
        ),
      );
    }
  }

  void _onServiceResetRequested(
    ServiceResetRequested event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      ServiceState.initial(
        state.config,
        initialBeneficiaries: state.beneficiaries,
      ).copyWith(
        availableBalanceKobo: state.availableBalanceKobo,
        providers: state.providers,
        utilityBeneficiaries: state.utilityBeneficiaries,
        utilityBeneficiariesPage: state.utilityBeneficiariesPage,
        hasReachedMaxUtilityBeneficiaries: state.hasReachedMaxUtilityBeneficiaries,
        contactBeneficiaries: state.contactBeneficiaries,
        contactBeneficiariesPage: state.contactBeneficiariesPage,
        hasReachedMaxContactBeneficiaries: state.hasReachedMaxContactBeneficiaries,
      ),
    );
  }

  Future<void> _onVerifyMeterRequested(
    ServiceVerifyMeterRequested event,
    Emitter<ServiceState> emit,
  ) async {
    final currentServiceId = serviceId;
    final providerId = state.selectedProviderId ?? state.selectedProvider;

    if (currentServiceId == null || currentServiceId.isEmpty) {
      emit(
        state.copyWith(
          isProcessing: false,
          errorMessage: 'Missing service configuration identifier.',
        ),
      );
      return;
    }

    // 1. Enter validation processing state (wipes old remnants immediately)
    emit(
      state.copyWith(
        isProcessing: true,
        errorMessage: null,
        verifiedCustomerName: null,
        minVendAmountKobo: null,
      ),
    );

    try {
      // 2. Await the Map<String, dynamic> response from the Repository
      final Map<String, dynamic> responseData = await _serviceRepository
          .verifyMeter(
            serviceId: currentServiceId,
            meterNumber: event.meterNumber.replaceAll(RegExp(r'\s+'), ''),
            providerId: providerId,
          );

      if (responseData['success'] == false ||
          responseData['status'] == 'failed') {
        final backendError =
            responseData['message'] ?? 'Meter verification failed.';
        throw Exception(backendError);
      }

      // 3. EXTRACT THE CUSTOMER NAME
      // Adapt the key string based on your specific backend JSON response body payload keys:
      // Common variations: responseData['customerName'], responseData['data']['name'], responseData['name']
      final dynamic dataObject = responseData['data'] ?? responseData;

      final String customerName =
          dataObject['customerName'] ??
          dataObject['name'] ??
          dataObject['customer_name'] ??
          'Valid Meter Account';

      final dynamic minVendVal = dataObject['minVendAmount'];
      int? minVendKobo;
      if (minVendVal is num) {
        minVendKobo = (minVendVal * 100).round();
      }

      final dynamic vendTypeVal = dataObject['vendType'];
      int? matchedIndex;
      String? matchedMeterType;
      int? defaultAmountKobo;
      String? defaultBundleCode;

      if (vendTypeVal is String) {
        final normalizedType = vendTypeVal.toUpperCase().trim();
        if (normalizedType == 'PREPAID') {
          matchedIndex = 0;
          matchedMeterType = 'prepaid';
        } else if (normalizedType == 'POSTPAID') {
          matchedIndex = 1;
          matchedMeterType = 'postpaid';
        }

        if (matchedIndex != null && matchedIndex < state.config.plans.length) {
          final plan = state.config.plans[matchedIndex];
          defaultAmountKobo = plan.amountKobo;
          defaultBundleCode = plan.bundleCode;
        }
      }

      // 4. SUCCESS EMISSION
      emit(
        state.copyWith(
          isProcessing: false,
          verifiedCustomerName: customerName,
          minVendAmountKobo: minVendKobo,
          selectedPlanIndex: matchedIndex ?? state.selectedPlanIndex,
          meterType: matchedMeterType ?? state.meterType,
          amountKobo: defaultAmountKobo ?? state.amountKobo,
          bundleCode: defaultBundleCode ?? state.bundleCode,
          errorMessage: null,
        ),
      );
    } catch (error) {
      // 5. ATOMIC FAILURE RETREAT
      emit(
        state.copyWith(
          isProcessing: false,
          verifiedCustomerName: null, // Keeps pay button completely locked
          minVendAmountKobo: null,
          errorMessage: extractError(error),
        ),
      );
    }
  }

  Future<void> _onInitRequested(
    ServiceInitRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(state.copyWith(isProvidersLoading: true));

    final providers = await _serviceRepository.getServiceProviders(
      event.serviceId,
    );

    emit(state.copyWith(isProvidersLoading: false, providers: providers));
  }

  void _onBalanceUpdated(
    ServiceBalanceUpdated event,
    Emitter<ServiceState> emit,
  ) {
    emit(state.copyWith(availableBalanceKobo: event.balanceKobo));
  }

  Future<void> _onUtilityBeneficiariesRequested(
    ServiceUtilityBeneficiariesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    if (state.hasReachedMaxUtilityBeneficiaries) return;
    if (state.isFetchingMoreUtilityBeneficiaries) return;

    final isInitial = state.utilityBeneficiaries.isEmpty;
    final nextPage = isInitial ? 1 : state.utilityBeneficiariesPage + 1;

    try {
      if (isInitial) {
        emit(state.copyWith(isProvidersLoading: true));
      } else {
        emit(state.copyWith(isFetchingMoreUtilityBeneficiaries: true));
      }

      final beneficiaries = await _serviceRepository.getUtilityBeneficiaries(
        page: nextPage,
        limit: 10,
      );

      final hasReachedMax = beneficiaries.length < 10;
      final updatedList = List<UtilityBeneficiary>.from(state.utilityBeneficiaries)
        ..addAll(beneficiaries);

      emit(
        state.copyWith(
          utilityBeneficiaries: updatedList,
          utilityBeneficiariesPage: nextPage,
          hasReachedMaxUtilityBeneficiaries: hasReachedMax,
          isFetchingMoreUtilityBeneficiaries: false,
          isProvidersLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('Failed to fetch utility beneficiaries: $e');
      emit(
        state.copyWith(
          isFetchingMoreUtilityBeneficiaries: false,
          isProvidersLoading: false,
        ),
      );
    }
  }

  void _onUtilityBeneficiarySelected(
    ServiceUtilityBeneficiarySelected event,
    Emitter<ServiceState> emit,
  ) {
    final beneficiary = event.beneficiary;
    final normalizedType = beneficiary.meterType.toUpperCase().trim();
    int matchedIndex = 0;
    String matchedMeterType = 'prepaid';

    if (normalizedType == 'PREPAID') {
      matchedIndex = 0;
      matchedMeterType = 'prepaid';
    } else if (normalizedType == 'POSTPAID') {
      matchedIndex = 1;
      matchedMeterType = 'postpaid';
    }

    final minVendKobo = (beneficiary.minAmount * 100).round();

    emit(
      state.copyWith(
        selectedProvider: beneficiary.providerName,
        selectedProviderId: beneficiary.serviceCategoryId,
        recipient: beneficiary.meterNumber,
        verifiedCustomerName: beneficiary.customerName,
        minVendAmountKobo: minVendKobo,
        selectedPlanIndex: matchedIndex,
        meterType: matchedMeterType,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onContactBeneficiariesRequested(
    ServiceContactBeneficiariesRequested event,
    Emitter<ServiceState> emit,
  ) async {
    if (state.hasReachedMaxContactBeneficiaries) return;
    if (state.isFetchingMoreContactBeneficiaries) return;

    final isInitial = state.contactBeneficiaries.isEmpty;
    final nextPage = isInitial ? 1 : state.contactBeneficiariesPage + 1;
    final title = state.config.title.toUpperCase().trim();
    final filter = (title == 'DATA' || title == 'INTERNET') ? 'INTERNET' : 'AIRTIME';

    try {
      if (isInitial) {
        emit(state.copyWith(isProvidersLoading: true));
      } else {
        emit(state.copyWith(isFetchingMoreContactBeneficiaries: true));
      }

      final beneficiaries = await _serviceRepository.getContactBeneficiaries(
        page: nextPage,
        limit: 10,
        filter: filter,
      );

      final hasReachedMax = beneficiaries.length < 10;
      final updatedList = List<ContactBeneficiary>.from(state.contactBeneficiaries)
        ..addAll(beneficiaries);

      emit(
        state.copyWith(
          contactBeneficiaries: updatedList,
          contactBeneficiariesPage: nextPage,
          hasReachedMaxContactBeneficiaries: hasReachedMax,
          isFetchingMoreContactBeneficiaries: false,
          isProvidersLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('Failed to fetch contact beneficiaries: $e');
      emit(
        state.copyWith(
          isFetchingMoreContactBeneficiaries: false,
          isProvidersLoading: false,
        ),
      );
    }
  }

  void _onContactBeneficiarySelected(
    ServiceContactBeneficiarySelected event,
    Emitter<ServiceState> emit,
  ) {
    final beneficiary = event.beneficiary;
    String providerName = '';
    try {
      final p = state.providers.firstWhere((prov) => prov.id == beneficiary.serviceCategoryId);
      providerName = p.name;
    } catch (_) {}

    emit(
      state.copyWith(
        recipient: beneficiary.phone,
        phoneNumber: beneficiary.phone,
        selectedProvider: providerName,
        selectedProviderId: beneficiary.serviceCategoryId,
        contactName: beneficiary.contactName,
        errorMessage: null,
      ),
    );

    final title = state.config.title.toLowerCase().trim();
    final isAirtime = title == 'airtime' || title == 'electricity';
    if (!isAirtime && beneficiary.serviceCategoryId.isNotEmpty) {
      add(ServiceProductsRequested(beneficiary.serviceCategoryId));
    }
  }
}
