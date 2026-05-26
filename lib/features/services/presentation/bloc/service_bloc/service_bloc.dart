import 'package:blithepay/features/services/data/models/beneficiary_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc({
    required ServiceConfig config,
    List<Beneficiary> initialBeneficiaries = const [],
  }) : super(ServiceState.initial(config, initialBeneficiaries: initialBeneficiaries)) {
    on<ServiceRecipientChanged>(_onRecipientChanged);
    on<ServiceProviderSelected>(_onProviderSelected);
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
  }

  void _onRecipientChanged(
    ServiceRecipientChanged event,
    Emitter<ServiceState> emit,
  ) {
    emit(state.copyWith(
      recipient: event.recipient,
      phoneNumber: event.recipient,
    ));
  }

  void _onProviderSelected(
    ServiceProviderSelected event,
    Emitter<ServiceState> emit,
  ) {
    emit(state.copyWith(selectedProvider: event.provider));
  }

  void _onPlanSelected(ServicePlanSelected event, Emitter<ServiceState> emit) {
    final plan = state.config.plans[event.index];
    emit(
      state.copyWith(
        selectedPlanIndex: event.index,
        amountKobo: plan.amountKobo,
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
    emit(ServiceState(
      config: state.config,
      recipient: state.recipient,
      selectedProvider: state.selectedProvider,
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
    ));
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

  void _onServicePinSubmitted(
    ServicePinSubmitted event,
    Emitter<ServiceState> emit,
  ) async {
    // optional: loading state
    emit(state.copyWith(isProcessing: true));

    try {
      // simulate API or call repository
      await Future.delayed(const Duration(milliseconds: 800));

      emit(state.copyWith(isProcessing: false, stage: ServiceStage.success));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, errorMessage: 'Invalid PIN'));
    }
  }
}
