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

  factory InvoiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InvoiceModel(
        id: '',
        invoiceNo: '',
        feeId: '',
        guardianId: '',
        studentId: '',
        status: '',
        dueAt: DateTime.now(),
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fee: FeeModel.fromJson(null),
      );
    }
    return InvoiceModel(
      id: json['id'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      feeId: json['feeId'] ?? '',
      guardianId: json['guardianId'] ?? '',
      studentId: json['studentId'] ?? '',
      status: json['status'] ?? '',
      dueAt: json['dueAt'] != null ? (DateTime.tryParse(json['dueAt']) ?? DateTime.now()) : DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? (DateTime.tryParse(json['updatedAt']) ?? DateTime.now()) : DateTime.now(),
      fee: FeeModel.fromJson(json['fee'] as Map<String, dynamic>?),
    );
  }
}

class ClassModel {
  final String id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ClassModel(id: '', name: '');
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class TermModel {
  final String id;
  final String name;

  TermModel({required this.id, required this.name});

  factory TermModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TermModel(id: '', name: '');
    return TermModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class AcademicSessionModel {
  final String id;
  final String name;

  AcademicSessionModel({required this.id, required this.name});

  factory AcademicSessionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AcademicSessionModel(id: '', name: '');
    return AcademicSessionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
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

  factory FeeBreakdownModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FeeBreakdownModel(
        id: '',
        name: '',
        amount: 0,
        isRequired: false,
      );
    }
    return FeeBreakdownModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] is String
          ? (num.tryParse(json['amount']) ?? 0)
          : (json['amount'] as num? ?? 0),
      isRequired: json['isRequired'] as bool? ?? false,
      amountInNaira: json['amountInNaira'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'amount': amount};
  }
}
