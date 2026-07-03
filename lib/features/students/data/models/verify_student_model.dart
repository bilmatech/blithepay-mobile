import 'package:blithepay/features/schools/data/models/school_model.dart';

class VerifiedStudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? image; // nullable
  final String regNumber;
  final ClassModel classModel;
  final SchoolModel school;

  VerifiedStudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.image,
    required this.regNumber,
    required this.classModel,
    required this.school,
  });

  factory VerifiedStudentModel.fromJson(Map<String, dynamic> json) {
    return VerifiedStudentModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      image: json['image'] as String?, // nullable
      regNumber: json['regNumber'] as String,
      classModel: ClassModel.fromJson(json['class'] as Map<String, dynamic>),
      school: SchoolModel.fromJson(json['school'] as Map<String, dynamic>),
    );
  }

  String get fullName => '$firstName $lastName';
}

class ClassModel {
  final String name;

  ClassModel({required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(name: json['name']);
  }
}

extension VerifiedStudentCardAdapter on VerifiedStudentModel {
  StudentCardData toStudentCardData() {
    return StudentCardData(
      id: id,
      fullName: fullName,
      regNumber: regNumber,
      className: classModel.name,
      schoolName: school.name,
    );
  }
}

class StudentCardData {
  final String id;
  final String fullName;
  final String regNumber;
  final String className;
  final String schoolName;
  final StudentCardStatus status;

  const StudentCardData({
    required this.id,
    required this.fullName,
    required this.regNumber,
    required this.className,
    required this.schoolName,
    this.status = StudentCardStatus.none,
  });
}

enum StudentCardStatus { none, pending, paid, overdue, unpaid }
