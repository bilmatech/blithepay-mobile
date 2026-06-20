enum ServiceStage { entry, review, success }

enum ServiceNetwork { mtn, glo, airtel, nineMobile }

class Beneficiary {
  final String id;
  final String phoneNumber;
  final ServiceNetwork network;

  const Beneficiary({
    required this.id,
    required this.phoneNumber,
    required this.network,
  });
}
