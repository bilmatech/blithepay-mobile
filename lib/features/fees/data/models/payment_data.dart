class WalletPaymentData {
  final String id;
  final String invoiceNo;
  final String feeId;
  final String guardianId;
  final String studentId;
  final String status;
  final DateTime dueAt;
  final DateTime paidAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletPaymentData({
    required this.id,
    required this.invoiceNo,
    required this.feeId,
    required this.guardianId,
    required this.studentId,
    required this.status,
    required this.dueAt,
    required this.paidAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletPaymentData.fromJson(Map<String, dynamic> json) {
    return WalletPaymentData(
      id: json['id'] as String,
      invoiceNo: json['invoiceNo'] as String,
      feeId: json['feeId'] as String,
      guardianId: json['guardianId'] as String,
      studentId: json['studentId'] as String,
      status: json['status'] as String,
      dueAt: DateTime.parse(json['dueAt']),
      paidAt: DateTime.parse(json['paidAt']),
      isDeleted: json['isDeleted'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class PaymentLink {
  final String authorizationUrl;
  final String accessCode;
  final String reference;

  PaymentLink({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    return PaymentLink(
      authorizationUrl: json['authorization_url'] ?? '',
      accessCode: json['access_code'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorization_url': authorizationUrl,
      'access_code': accessCode,
      'reference': reference,
    };
  }
}