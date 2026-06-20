part of 'service_bloc.dart';

abstract class ServiceEvent {}

class ServiceRecipientChanged extends ServiceEvent {
  final String recipient;

  ServiceRecipientChanged(this.recipient);
}

class ServiceProviderSelected extends ServiceEvent {
  final String provider;
  final String? providerId;
  final String? bundleCode;

  ServiceProviderSelected(this.provider, {this.providerId, this.bundleCode});
}

class ServiceProvidersRequested extends ServiceEvent {
  final String serviceId;

  ServiceProvidersRequested(this.serviceId);
}

class ServiceProductsRequested extends ServiceEvent {
  final String providerId;

  ServiceProductsRequested(this.providerId);
}

class ServicePlanSelected extends ServiceEvent {
  final int index;

  ServicePlanSelected(this.index);
}

class ServiceAmountSelected extends ServiceEvent {
  final int amountKobo;

  ServiceAmountSelected(this.amountKobo);
}

class ServiceReviewRequested extends ServiceEvent {
  ServiceReviewRequested();
}

class ServiceReviewClosed extends ServiceEvent {
  ServiceReviewClosed();
}

class ServicePinRequested extends ServiceEvent {
  ServicePinRequested();
}

class ServicePinDigitPressed extends ServiceEvent {
  final String digit;

  ServicePinDigitPressed(this.digit);
}

class ServicePinBackspacePressed extends ServiceEvent {
  ServicePinBackspacePressed();
}

class ServiceSuccessDismissed extends ServiceEvent {
  ServiceSuccessDismissed();
}

class ServiceBeneficiaryListToggled extends ServiceEvent {
  ServiceBeneficiaryListToggled();
}

class ServiceBeneficiarySelected extends ServiceEvent {
  final Beneficiary beneficiary;

  ServiceBeneficiarySelected(this.beneficiary);
}

class ServiceBeneficiaryRemoved extends ServiceEvent {
  final String beneficiaryId;

  ServiceBeneficiaryRemoved(this.beneficiaryId);
}

class ServiceBeneficiariesCleared extends ServiceEvent {
  ServiceBeneficiariesCleared();
}

class ServicePinSubmitted extends ServiceEvent {
  final String pin;

  ServicePinSubmitted(this.pin);
}

class ServiceNetworkDetected extends ServiceEvent {
  final ServiceNetwork? network;

  ServiceNetworkDetected(this.network);
}

class ServiceResetRequested extends ServiceEvent {
  ServiceResetRequested();
}

class ServiceVerifyMeterRequested extends ServiceEvent {
  final String meterNumber;
  ServiceVerifyMeterRequested(this.meterNumber);

  @override
  List<Object?> get props => [meterNumber];
}


class ServiceInitRequested extends ServiceEvent {
  final String serviceId;
  ServiceInitRequested(this.serviceId);
}