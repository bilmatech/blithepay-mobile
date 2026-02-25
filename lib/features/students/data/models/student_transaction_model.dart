class PaginatedStudentTransactionModel {
  final List<StudentTransactionModel> transactions;
  final int currentPage;
  final int totalPages;
  final int? nextPage;

  PaginatedStudentTransactionModel({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
  });

  factory PaginatedStudentTransactionModel.fromJson(Map<String, dynamic> json) {
    final mainData = json['data'];
    final List<dynamic> transactionJson = mainData['data'];
    final metadata = mainData['metadata'];

    return PaginatedStudentTransactionModel(
      transactions: transactionJson
          .map((e) => StudentTransactionModel.fromJson(e))
          .toList(),
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }
}

class StudentTransactionModel {
  final String id;
  final String guardianId;
  final String schoolId;
  final String studentId;
  final String invoiceId;
  final String reference;
  final String amount;
  final String latePaymentFee;
  final String vatAmount;
  final String status;
  final DateTime transactionAt;
  final DateTime processedAt;
  final String description;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Student student;

  StudentTransactionModel({
    required this.id,
    required this.guardianId,
    required this.schoolId,
    required this.studentId,
    required this.invoiceId,
    required this.reference,
    required this.amount,
    required this.latePaymentFee,
    required this.vatAmount,
    required this.status,
    required this.transactionAt,
    required this.processedAt,
    required this.description,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.student,
  });

  factory StudentTransactionModel.fromJson(Map<String, dynamic> json) {
    return StudentTransactionModel(
      id: json['id'] as String,
      guardianId: json['guardianId'] as String,
      schoolId: json['schoolId'] as String,
      studentId: json['studentId'] as String,
      invoiceId: json['invoiceId'] as String,
      reference: json['reference'] as String,
      amount: json['amount'] as String,
      latePaymentFee: json['latePaymentFee'] as String,
      vatAmount: json['vatAmount'] as String,
      status: json['status'] as String,
      transactionAt: DateTime.parse(json['transactionAt'] as String),
      processedAt: DateTime.parse(json['processedAt'] as String),
      description: json['description'] as String,
      isDeleted: json['isDeleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'guardianId': guardianId,
    'schoolId': schoolId,
    'studentId': studentId,
    'invoiceId': invoiceId,
    'reference': reference,
    'amount': amount,
    'latePaymentFee': latePaymentFee,
    'vatAmount': vatAmount,
    'status': status,
    'transactionAt': transactionAt.toIso8601String(),
    'processedAt': processedAt.toIso8601String(),
    'description': description,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'student': student.toJson(),
  };
}

class Student {
  final String id;
  final String firstName;
  final String lastName;

  Student({required this.id, required this.firstName, required this.lastName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
  };
}
