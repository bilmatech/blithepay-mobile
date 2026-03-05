import 'package:blithepay/features/students/data/models/verify_student_model.dart';

class PaginatedStudents {
  final List<VerifiedStudentModel> students;
  final int currentPage;
  final int totalPages;
  final int? nextPage;

  PaginatedStudents({
    required this.students,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
  });
}

class StudentModel {
  final String id;
  final String name;
  final String studentId;
  final String class_;
  final String school;
  final String feeStatus; // Pending, Paid, Partial
  final double amountDue;

  StudentModel({
    required this.id,
    required this.name,
    required this.studentId,
    required this.class_,
    required this.school,
    required this.feeStatus,
    required this.amountDue,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      studentId: json['studentId'],
      class_: json['class'],
      school: json['school'],
      feeStatus: json['feeStatus'],
      amountDue: (json['amountDue'] as num).toDouble(),
    );
  }
}
