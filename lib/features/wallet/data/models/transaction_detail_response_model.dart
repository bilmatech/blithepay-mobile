import 'package:blithepay/features/vas/core/data/models/contact_beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/models/utility_beneficiary_model.dart';
import 'package:blithepay/features/vas/core/data/models/cable_tv_beneficiary_model.dart';

class TransactionDetailResponseModel {
  final bool status;
  final String message;
  final AppTransactionDetailData data;

  TransactionDetailResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransactionDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: AppTransactionDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class AppTransactionDetailData {
  final String id;
  final String userId;
  final bool isDeleted;
  final String updatedAt;
  final String createdAt;
  final int version;
  final VasDetailModel? vas;
  final TransactionDetailDetailsModel details;

  AppTransactionDetailData({
    required this.id,
    required this.userId,
    required this.isDeleted,
    required this.updatedAt,
    required this.createdAt,
    required this.version,
    this.vas,
    required this.details,
  });

  factory AppTransactionDetailData.fromJson(Map<String, dynamic> json) {
    return AppTransactionDetailData(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      vas: json['vas'] != null
          ? VasDetailModel.fromJson(json['vas'] as Map<String, dynamic>)
          : null,
      details: TransactionDetailDetailsModel.fromJson(
          json['details'] as Map<String, dynamic>),
    );
  }
}

class VasDetailModel {
  final String id;
  final String transactionId;
  final String reference;
  final String status;
  final int amount;
  final dynamic commission;
  final String externalTransactionId;
  final String? token;
  final String? tokenUnits;
  final Map<String, dynamic>? metadata;
  final String? phoneContactId;
  final String? utilityCustomerId;
  final String? cabletvCustomerId;
  final String? paymentMethod;
  final bool isDeleted;
  final String updatedAt;
  final String createdAt;
  final ContactBeneficiary? phone;
  final UtilityBeneficiary? utility;
  final CableTvBeneficiary? cabletv;

  VasDetailModel({
    required this.id,
    required this.transactionId,
    required this.reference,
    required this.status,
    required this.amount,
    this.commission,
    required this.externalTransactionId,
    this.token,
    this.tokenUnits,
    this.metadata,
    this.phoneContactId,
    this.utilityCustomerId,
    this.cabletvCustomerId,
    this.paymentMethod,
    required this.isDeleted,
    required this.updatedAt,
    required this.createdAt,
    this.phone,
    this.utility,
    this.cabletv,
  });

  factory VasDetailModel.fromJson(Map<String, dynamic> json) {
    return VasDetailModel(
      id: json['id'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      commission: json['commission'],
      externalTransactionId: json['externalTransactionId'] as String? ?? '',
      token: json['token'] as String?,
      tokenUnits: json['tokenUnits'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      phoneContactId: json['phoneContactId'] as String?,
      utilityCustomerId: json['utilityCustomerId'] as String?,
      cabletvCustomerId: json['cabletvCustomerId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      phone: json['phone'] != null
          ? ContactBeneficiary.fromJson(json['phone'] as Map<String, dynamic>)
          : null,
      utility: json['utility'] != null
          ? UtilityBeneficiary.fromJson(json['utility'] as Map<String, dynamic>)
          : null,
      cabletv: json['cabletv'] != null
          ? CableTvBeneficiary.fromJson(json['cabletv'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransactionDetailDetailsModel {
  final String id;
  final String reference;
  final String idempotencyKey;
  final String? relatedTransactionId;
  final String status;
  final String type;
  final String description;
  final String currency;
  final int amount;
  final Map<String, dynamic>? metadata;
  final bool isDeleted;
  final String updatedAt;
  final String createdAt;

  TransactionDetailDetailsModel({
    required this.id,
    required this.reference,
    required this.idempotencyKey,
    this.relatedTransactionId,
    required this.status,
    required this.type,
    required this.description,
    required this.currency,
    required this.amount,
    this.metadata,
    required this.isDeleted,
    required this.updatedAt,
    required this.createdAt,
  });

  factory TransactionDetailDetailsModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailDetailsModel(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      relatedTransactionId: json['relatedTransactionId'] as String?,
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      currency: json['currency'] as String? ?? 'NGN',
      amount: json['amount'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: json['updatedAt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
