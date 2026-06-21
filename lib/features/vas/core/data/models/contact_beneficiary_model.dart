class ContactBeneficiary {
  final String id;
  final String userId;
  final String phone;
  final String contactType;
  final String provider;
  final String serviceCategoryId;
  final String? contactName;
  final int usageCount;

  const ContactBeneficiary({
    required this.id,
    required this.userId,
    required this.phone,
    required this.contactType,
    required this.provider,
    required this.serviceCategoryId,
    this.contactName,
    required this.usageCount,
  });

  factory ContactBeneficiary.fromJson(Map<String, dynamic> json) {
    return ContactBeneficiary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      phone: json['phone'] as String,
      contactType: json['contactType'] as String,
      provider: json['provider'] as String,
      serviceCategoryId: json['serviceCategoryId'] as String,
      contactName: json['contactName'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }
}
