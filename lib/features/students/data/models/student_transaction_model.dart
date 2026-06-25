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

  factory StudentTransactionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StudentTransactionModel(
        id: '',
        guardianId: '',
        schoolId: '',
        studentId: '',
        invoiceId: '',
        reference: '',
        amount: '',
        latePaymentFee: '',
        vatAmount: '',
        status: '',
        transactionAt: DateTime.now(),
        processedAt: DateTime.now(),
        description: '',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        student: Student(id: '', firstName: '', lastName: ''),
      );
    }
    return StudentTransactionModel(
      id: json['id'] ?? '',
      guardianId: json['guardianId'] ?? '',
      schoolId: json['schoolId'] ?? '',
      studentId: json['studentId'] ?? '',
      invoiceId: json['invoiceId'] ?? '',
      reference: json['reference'] ?? '',
      amount: json['amount']?.toString() ?? '',
      latePaymentFee: json['latePaymentFee']?.toString() ?? '',
      vatAmount: json['vatAmount']?.toString() ?? '',
      status: json['status'] ?? '',
      transactionAt: json['transactionAt'] != null ? (DateTime.tryParse(json['transactionAt']) ?? DateTime.now()) : DateTime.now(),
      processedAt: json['processedAt'] != null ? (DateTime.tryParse(json['processedAt']) ?? DateTime.now()) : DateTime.now(),
      description: json['description'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? (DateTime.tryParse(json['updatedAt']) ?? DateTime.now()) : DateTime.now(),
      student: Student.fromJson(json['student'] as Map<String, dynamic>?),
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

  factory Student.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Student(id: '', firstName: '', lastName: '');
    return Student(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
  };
}
