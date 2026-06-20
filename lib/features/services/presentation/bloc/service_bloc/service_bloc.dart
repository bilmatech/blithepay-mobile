import 'dart:developer' as developer;

import 'package:blithepay/features/services/data/models/beneficiary_model.dart';
import 'package:blithepay/features/services/data/models/service_model.dart';
import 'package:blithepay/features/services/data/models/service_purchase_response.dart';
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
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

    if (serviceId != null && serviceId!.isNotEmpty) {
      add(ServiceProvidersRequested(serviceId!));
    }
  }

  void _onRecipientChanged(
    ServiceRecipientChanged event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(recipient: event.recipient, phoneNumber: event.recipient),
    );
  }

  void _onProviderSelected(
    ServiceProviderSelected event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(
        selectedProvider: event.provider,
        selectedProviderId: event.providerId ?? state.selectedProviderId,
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
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onProductsRequested(
    ServiceProductsRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(state.copyWith(isProductsLoading: true, errorMessage: null));
    try {
      final products = await _serviceRepository.getProviderProducts(
        event.providerId,
      );
      emit(
        state.copyWith(
          isProductsLoading: false,
          products: products,
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

  void _onPlanSelected(ServicePlanSelected event, Emitter<ServiceState> emit) {
    final plan = state.config.plans[event.index];
    emit(
      state.copyWith(
        selectedPlanIndex: event.index,
        amountKobo: plan.amountKobo,
        bundleCode: plan.bundleCode,
      ),
    );
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
    emit(state.copyWith(stage: ServiceStage.entry, pin: ''));
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
    emit(ServiceState.initial(state.config));
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
        isProcessing: state.isProcessing,
        errorMessage: state.errorMessage,
        bundleCode: state.bundleCode,
        meterType: state.meterType,
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
    emit(state.copyWith(isProcessing: true, errorMessage: null));

    try {
      await _performServicePurchase(event.pin, emit);
      emit(
        state.copyWith(
          isProcessing: false,
          stage: ServiceStage.success,
          errorMessage: null,
        ),
      );
    } catch (error) {
      final errorMessage = error is Exception
          ? error.toString()
          : 'Payment failed';
      emit(
        state.copyWith(
          isProcessing: false,
          stage: ServiceStage.entry,
          pin: '',
          errorMessage: errorMessage,
        ),
      );
    }
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

      final title = state.config.title.toLowerCase().trim();
      switch (title) {
        case 'airtime':
          transactionResult = await _serviceRepository.purchaseAirtime(
            serviceId: serviceId,
            recipient: state.recipient,
            providerId: providerId,
            amountKobo: state.amountKobo,
            challengeToken: token,
          );
          break;
        case 'data':
        case 'internet':
          transactionResult = await _serviceRepository.purchaseInternet(
            serviceId: serviceId,
            recipient: state.recipient,
            bundleCode: state.bundleCode,
            amountKobo: state.amountKobo,
            challengeToken: token,
          );
          break;
        case 'electricity':
        case 'utility':
          await _serviceRepository.verifyMeter(
            serviceId: serviceId,
            meterNumber: state.recipient,
            providerId: providerId,
          );
          transactionResult = await _serviceRepository.purchaseUtility(
            serviceId: serviceId,
            meterNumber: state.recipient,
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
          errorMessage: error.toString().replaceAll('Exception:', '').trim(),
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
      ServiceState.initial(state.config),
    ); // Keep config settings but wipe input values
  }
}
