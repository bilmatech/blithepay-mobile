import 'package:intl/intl.dart';
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

  static String formattedDateTime(String date) {
    final dateTime = DateTime.parse(date).toLocal();
    return DateFormat('dd-MM-yy  HH:mm').format(dateTime);
  }

  static String formattedAmount(String amount, {String? flow}) {
    final amountValue = double.tryParse(amount) ?? 0.0;

    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    );

    final formatted = formatter.format(amountValue);

    return flow != null
        ? flow.toLowerCase() == 'inflow'
              ? '+$formatted'
              : '-$formatted'
        : formatted;
  }
}
