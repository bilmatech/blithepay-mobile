import 'package:blithepay/features/students/data/models/invoice_model.dart';


class Fee {
  final String id;
  final String name;
  final DateTime dueAt;
  final String latePaymentFee;
  final String latePaymentFeeInNaira;
  final bool isPublished;
  final DateTime publishedAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<FeeBreakdownModel> feeBreakdowns;
  final ClassModel feeClass;
  final TermModel term;
  final AcademicSessionModel academicSession;

  const Fee({
    required this.id,
    required this.name,
    required this.dueAt,
    required this.latePaymentFee,
    required this.latePaymentFeeInNaira,
    required this.isPublished,
    required this.publishedAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.feeBreakdowns,
    required this.feeClass,
    required this.term,
    required this.academicSession,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'],
      name: json['name'],
      dueAt: DateTime.parse(json['dueAt']),
      latePaymentFee: json['latePaymentFee'],
      latePaymentFeeInNaira: json['latePaymentFeeInNaira'],
      isPublished: json['isPublished'],
      publishedAt: DateTime.parse(json['publishedAt']),
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      feeBreakdowns: (json['feeBreakdowns'] as List)
          .map((e) => FeeBreakdownModel.fromJson(e))
          .toList(),
      feeClass: ClassModel.fromJson(json['class']),
      term: TermModel.fromJson(json['term']),
      academicSession:
          AcademicSessionModel.fromJson(json['academicSession']),
    );
  }

  /// Useful computed property
  int get totalAmount =>
      feeBreakdowns.fold(0, (sum, f) => sum + f.amount);
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
