import 'package:blithepay/features/vas/core/data/models/beneficiary_model.dart';

/// Detects the Nigerian mobile network from a phone number string.
/// Handles both local (080x) and international (+234 / 234) formats.
/// Returns null when the prefix is unrecognised or the number is too short.
ServiceNetwork? detectNigerianNetwork(String phoneNumber) {
  final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

  String prefix;
  if (digits.startsWith('234') && digits.length >= 6) {
    prefix = '0${digits.substring(3, 6)}';
  } else if (digits.length >= 4) {
    prefix = digits.substring(0, 4);
  } else {
    return null;
  }

  const mtn = [
    '0703', '0706', '0803', '0806', '0810', '0813', '0814', '0816',
    '0903', '0906', '0913', '0916',
  ];
  const glo = ['0705', '0805', '0807', '0811', '0815', '0905'];
  const airtel = [
    '0701', '0708', '0802', '0808', '0812',
    '0901', '0902', '0907',
  ];
  const nineMobile = ['0809', '0817', '0818', '0908', '0909'];

  if (mtn.contains(prefix)) return ServiceNetwork.mtn;
  if (glo.contains(prefix)) return ServiceNetwork.glo;
  if (airtel.contains(prefix)) return ServiceNetwork.airtel;
  if (nineMobile.contains(prefix)) return ServiceNetwork.nineMobile;
  return null;
}

/// Human-readable short label for display inside badges and chips.
String networkShortLabel(ServiceNetwork network) => switch (network) {
      ServiceNetwork.mtn => 'MTN',
      ServiceNetwork.glo => 'GLO',
      ServiceNetwork.airtel => 'AIR',
      ServiceNetwork.nineMobile => '9MB',
    };

/// Full carrier name.
String networkFullLabel(ServiceNetwork network) => switch (network) {
      ServiceNetwork.mtn => 'MTN',
      ServiceNetwork.glo => 'Glo',
      ServiceNetwork.airtel => 'Airtel',
      ServiceNetwork.nineMobile => '9mobile',
    };
