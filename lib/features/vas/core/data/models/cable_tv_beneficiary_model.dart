class CableTvBeneficiary {
  final String id;
  final String userId;
  final String smartcardNumber;
  final String customerName;
  final String serviceCategoryId;
  final String? bundleCode;
  final double? amount;
  final dynamic metadata;
  final bool isDeleted;
  final String updatedAt;
  final String createdAt;

  const CableTvBeneficiary({
    required this.id,
    required this.userId,
    required this.smartcardNumber,
    required this.customerName,
    required this.serviceCategoryId,
    this.bundleCode,
    this.amount,
    this.metadata,
    required this.isDeleted,
    required this.updatedAt,
    required this.createdAt,
  });

  factory CableTvBeneficiary.fromJson(Map<String, dynamic> json) {
    return CableTvBeneficiary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      smartcardNumber: json['smartcardNumber'] as String,
      customerName: json['customerName'] as String,
      serviceCategoryId: json['serviceCategoryId'] as String,
      bundleCode: json['bundleCode'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      metadata: json['metadata'],
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
