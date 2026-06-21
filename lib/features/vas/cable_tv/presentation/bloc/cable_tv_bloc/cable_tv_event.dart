part of 'cable_tv_bloc.dart';

abstract class CableTvEvent {}

class CableTvSmartcardChanged extends CableTvEvent {
  final String value;
  CableTvSmartcardChanged(this.value);
}

class CableTvProviderSelected extends CableTvEvent {
  final String provider; // provider name (for display/state)
  final String providerId; // provider id (for API calls)
  CableTvProviderSelected(this.provider, {required this.providerId});
}

class CableTvVerifyRequested extends CableTvEvent {}

class CableTvPackageSelected extends CableTvEvent {
  final int index;
  CableTvPackageSelected(this.index);
}

class CableTvAmountSelected extends CableTvEvent {
  final int amountKobo;
  CableTvAmountSelected(this.amountKobo);
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

class CableTvBalanceUpdated extends CableTvEvent {
  final int balanceKobo;
  CableTvBalanceUpdated(this.balanceKobo);
}

class CableTvBeneficiariesRequested extends CableTvEvent {}

class CableTvBeneficiarySelected extends CableTvEvent {
  final CableTvBeneficiary beneficiary;
  CableTvBeneficiarySelected(this.beneficiary);
}
