import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.h3),
      content: Text(message, style: AppTextStyles.bodyRegular),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
