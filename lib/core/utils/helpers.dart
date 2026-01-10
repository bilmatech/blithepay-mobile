import 'package:uuid/uuid.dart';

class Helpers {
  static String generateUUID() => const Uuid().v4();

  static String formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static bool isEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
