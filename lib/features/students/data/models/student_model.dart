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
}
