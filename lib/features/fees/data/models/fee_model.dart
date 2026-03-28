import 'package:blithepay/features/students/data/models/invoice_model.dart';

class Fee {
  final String id;
  final String name;
  final DateTime? dueAt;

  final String? latePaymentFee;
  final String? latePaymentFeeInNaira;

  final bool? isPublished;
  final DateTime? publishedAt;

  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<FeeBreakdownModel> feeBreakdowns;

  final ClassModel? feeClass;
  final TermModel? term;
  final AcademicSessionModel? academicSession;

  const Fee({
    required this.id,
    required this.name,
    this.dueAt,
    this.latePaymentFee,
    this.latePaymentFeeInNaira,
    this.isPublished,
    this.publishedAt,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    required this.feeBreakdowns,
    this.feeClass,
    this.term,
    this.academicSession,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    final breakdowns = json['feeBreakdowns'] as List?;

    return Fee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',

      dueAt: json['dueAt'] != null ? DateTime.tryParse(json['dueAt']) : null,

      latePaymentFee: json['latePaymentFee']?.toString(),
      latePaymentFeeInNaira: json['latePaymentFeeInNaira']?.toString(),

      isPublished: json['isPublished'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,

      isDeleted: json['isDeleted'],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,

      feeBreakdowns: breakdowns == null
          ? []
          : breakdowns.map((e) => FeeBreakdownModel.fromJson(e)).toList(),

      feeClass: json['class'] != null
          ? ClassModel.fromJson(json['class'])
          : null,

      term: json['term'] != null ? TermModel.fromJson(json['term']) : null,

      academicSession: json['academicSession'] != null
          ? AcademicSessionModel.fromJson(json['academicSession'])
          : null,
    );
  }

  /// Works with decimal amounts
  // double get totalAmount => feeBreakdowns.fold(
  //   0.0,
  //   (sum, f) => sum + (double.tryParse(f.amount.toString()) ?? 0),
  // );
}

class FeeModel {
  final String id;
  final String name;
  final DateTime dueAt;
  final String latePaymentFee;
  final ClassModel classModel;
  final TermModel term;
  final AcademicSessionModel academicSession;
  final List<FeeBreakdownModel>? feeBreakdowns;

  FeeModel({
    required this.id,
    required this.name,
    required this.dueAt,
    required this.latePaymentFee,
    required this.classModel,
    required this.term,
    required this.academicSession,
    this.feeBreakdowns,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    final breakdowns = json['feeBreakdowns'] as List<dynamic>?;

    return FeeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dueAt: DateTime.parse(json['dueAt']),
      latePaymentFee: json['latePaymentFee'] ?? '0',
      classModel: ClassModel.fromJson(json['class']),
      term: TermModel.fromJson(json['term']),
      academicSession: AcademicSessionModel.fromJson(json['academicSession']),
      feeBreakdowns: breakdowns
          ?.map((e) => FeeBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
