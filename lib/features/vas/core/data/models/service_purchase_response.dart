class ServicePurchaseResponse<T> {
  final bool status;
  final String message;
  final T data;

  const ServicePurchaseResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServicePurchaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromDataJson,
  ) {
    return ServicePurchaseResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: fromDataJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ChargeModel {
  final String authorizationUrl;
  final String accessCode;
  final String reference;

  const ChargeModel({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  factory ChargeModel.fromJson(Map<String, dynamic> json) {
    return ChargeModel(
      authorizationUrl: json['authorization_url'] as String? ?? json['authorizationUrl'] as String? ?? '',
      accessCode: json['access_code'] as String? ?? json['accessCode'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }
}

class ServiceTransactionModel {
  final String id;
  final String transactionId;
  final String reference;
  final String status;
  final double amount;
  final double? commission;
  final String? externalTransactionId;
  final String? token;
  final String? tokenUnits;
  final PurchaseMetadataModel? metadata;
  final String? phoneContactId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChargeModel? charge;

  const ServiceTransactionModel({
    required this.id,
    required this.transactionId,
    required this.reference,
    required this.status,
    required this.amount,
    this.commission,
    this.externalTransactionId,
    this.token,
    this.tokenUnits,
    this.metadata,
    this.phoneContactId,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.charge,
  });

  factory ServiceTransactionModel.fromJson(Map<String, dynamic> json) {
    return ServiceTransactionModel(
      id: json['id'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      commission: (json['commission'] as num?)?.toDouble(),
      externalTransactionId: json['externalTransactionId'] as String?,
      token: json['token'] as String?,
      tokenUnits: json['tokenUnits'] as String?,
      metadata: json['metadata'] != null
          ? PurchaseMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      phoneContactId: json['phoneContactId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      charge: json['charge'] != null
          ? ChargeModel.fromJson(json['charge'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PurchaseMetadataModel {
  final String id;
  final double amount;
  final String status;
  final String clientId;
  final String reference;
  final String serviceCategoryId;
  final ReceiverModel receiver;
  final Map<String, dynamic> rawJson;

  const PurchaseMetadataModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.clientId,
    required this.reference,
    required this.serviceCategoryId,
    required this.receiver,
    required this.rawJson,
  });

  factory PurchaseMetadataModel.fromJson(Map<String, dynamic> json) {
    return PurchaseMetadataModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      clientId: json['clientId'] as String,
      reference: json['reference'] as String,
      serviceCategoryId: json['serviceCategoryId'] as String,
      receiver: ReceiverModel.fromJson(json['receiver'] as Map<String, dynamic>),
      rawJson: json,
    );
  }
}

class ReceiverModel {
  final String? name;
  final String number;
  final String? address;
  final String? vendType;
  final String? distribution;

  const ReceiverModel({
    this.name,
    required this.number,
    this.address,
    this.vendType,
    this.distribution,
  });

  factory ReceiverModel.fromJson(Map<String, dynamic> json) {
    return ReceiverModel(
      name: json['name'] as String?,
      number: json['number'] as String,
      address: json['address'] as String?,
      vendType: json['vendType'] as String?,
      distribution: json['distribution'] as String?,
    );
  }
}