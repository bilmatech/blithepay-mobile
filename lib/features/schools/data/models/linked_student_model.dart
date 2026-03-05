class LinkedStudentModel {
  final String id;
  final String schoolId;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? image;
  final String classId;
  final String guardianId;
  final String regNumber;
  final String status;
  final bool isLinked;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  LinkedStudentModel({
    required this.id,
    required this.schoolId,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.image,
    required this.classId,
    required this.guardianId,
    required this.regNumber,
    required this.status,
    required this.isLinked,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LinkedStudentModel.fromJson(Map<String, dynamic> json) {
    return LinkedStudentModel(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      image: json['image'] as String?,
      classId: json['classId'] as String,
      guardianId: json['guardianId'] as String,
      regNumber: json['regNumber'] as String,
      status: json['status'] as String,
      isLinked: json['isLinked'] as bool,
      isDeleted: json['isDeleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'image': image,
      'classId': classId,
      'guardianId': guardianId,
      'regNumber': regNumber,
      'status': status,
      'isLinked': isLinked,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }
}
