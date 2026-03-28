import 'package:blithepay/features/fees/data/models/fee_model.dart';

class PaginatedInvoiceModel {
  final List<InvoiceModel> invoices;
  final int currentPage;
  final int totalPages;
  final int? nextPage;

  PaginatedInvoiceModel({
    required this.invoices,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
  });

  factory PaginatedInvoiceModel.fromJson(Map<String, dynamic> json) {
    final mainData = json['data'] as Map<String, dynamic>;
    final List<dynamic> invoicesJson = mainData['data'] ?? [];
    final metadata = mainData['metadata'] as Map<String, dynamic>;

    return PaginatedInvoiceModel(
      invoices: invoicesJson.map((e) => InvoiceModel.fromJson(e)).toList(),
      currentPage: metadata['page'] ?? 1,
      totalPages: metadata['totalPages'] ?? 1,
      nextPage: metadata['nextPage'],
    );
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNo;
  final String feeId;
  final String guardianId;
  final String studentId;
  final String status;
  final DateTime dueAt;
  final DateTime? paidAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeeModel fee;

  InvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.feeId,
    required this.guardianId,
    required this.studentId,
    required this.status,
    required this.dueAt,
    this.paidAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.fee,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      feeId: json['feeId'] ?? '',
      guardianId: json['guardianId'] ?? '',
      studentId: json['studentId'] ?? '',
      status: json['status'] ?? '',
      dueAt: DateTime.parse(json['dueAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      fee: FeeModel.fromJson(json['fee']),
    );
  }
}

class ClassModel {
  final String id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class TermModel {
  final String id;
  final String name;

  TermModel({required this.id, required this.name});

  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class AcademicSessionModel {
  final String id;
  final String name;

  AcademicSessionModel({required this.id, required this.name});

  factory AcademicSessionModel.fromJson(Map<String, dynamic> json) {
    return AcademicSessionModel(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class FeeBreakdownModel {
  final String id;
  final String name;
  final num amount;
  final bool isRequired;
  final String? amountInNaira;

  FeeBreakdownModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.isRequired,
    this.amountInNaira,
  });

  factory FeeBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FeeBreakdownModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] is String
          ? num.parse(json['amount'])
          : json['amount'] as num,
      isRequired: json['isRequired'] as bool,
      amountInNaira: json['amountInNaira'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'amount': amount};
  }
}
