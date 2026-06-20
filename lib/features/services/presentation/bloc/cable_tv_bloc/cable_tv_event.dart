part of 'cable_tv_bloc.dart';

abstract class CableTvEvent {}

class CableTvSmartcardChanged extends CableTvEvent {
  final String value;
  CableTvSmartcardChanged(this.value);
}

class CableTvProviderSelected extends CableTvEvent {
  final String provider;
  CableTvProviderSelected(this.provider);
}

class CableTvVerifyRequested extends CableTvEvent {}

class CableTvPackageSelected extends CableTvEvent {
  final int index;
  CableTvPackageSelected(this.index);
}

class CableTvContinueToConfirmation extends CableTvEvent {}

class CableTvBack extends CableTvEvent {}

class CableTvBeneficiaryRenewSelected extends CableTvEvent {
  final CableTvSmartcard smartcard;
  CableTvBeneficiaryRenewSelected(this.smartcard);
}

class CableTvBeneficiaryChangeSelected extends CableTvEvent {
  final CableTvSmartcard smartcard;
  CableTvBeneficiaryChangeSelected(this.smartcard);
}

class CableTvPayRequested extends CableTvEvent {
  final String pin;
  CableTvPayRequested(this.pin);
}

class CableTvSuccessDismissed extends CableTvEvent {}

class CableTvProductsRequested extends CableTvEvent {
  final String providerId;
  CableTvProductsRequested(this.providerId);
}

class CableTvInitRequested extends CableTvEvent {}
