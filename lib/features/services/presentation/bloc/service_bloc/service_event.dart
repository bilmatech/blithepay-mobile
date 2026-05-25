part of 'service_bloc.dart';

abstract class ServiceEvent {}

class ServiceRecipientChanged extends ServiceEvent {
  final String recipient;

  ServiceRecipientChanged(this.recipient);
}

class ServiceProviderSelected extends ServiceEvent {
  final String provider;

  ServiceProviderSelected(this.provider);
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
