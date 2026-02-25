import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';

class FeeSelectionArgs {
  final String studentCode;
  final VerifiedStudentModel student;
  final InvoiceModel invoice;

  FeeSelectionArgs({
    required this.studentCode,
    required this.student,
    required this.invoice,
  });
}
