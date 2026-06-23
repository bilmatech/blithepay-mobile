class UtilityBeneficiary {
  final String id;
  final String userId;
  final String meterNumber;
  final String meterType;
  final String providerName;
  final String serviceCategoryId;
  final String customerName;
  final String? customerAddress;
  final double minAmount;
  final double maxAmount;

  const UtilityBeneficiary({
    required this.id,
    required this.userId,
    required this.meterNumber,
    required this.meterType,
    required this.providerName,
    required this.serviceCategoryId,
    required this.customerName,
    this.customerAddress,
    required this.minAmount,
    required this.maxAmount,
  });

  factory UtilityBeneficiary.fromJson(Map<String, dynamic> json) {
    return UtilityBeneficiary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      meterNumber: json['meterNumber'] as String,
      meterType: json['meterType'] as String,
      providerName: json['providerName'] as String,
      serviceCategoryId: json['serviceCategoryId'] as String,
      customerName: json['customerName'] as String,
      customerAddress: json['customerAddress'] as String?,
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
    );
  }
}
