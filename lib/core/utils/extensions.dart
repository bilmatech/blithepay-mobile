extension StringExtensions on String {
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(this);
  }

  bool isValidPhone() {
    return length >= 10;
  }

  bool isStrongPassword() {
    return length >= 8 && contains(RegExp(r'[A-Z]')) && contains(RegExp(r'[0-9]'));
  }

  String toTitleCase() {
    return split(' ').map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}').join(' ');
  }
}

extension DateTimeExtensions on DateTime {
  String toFormattedString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
