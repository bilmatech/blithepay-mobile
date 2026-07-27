import 'package:flutter/material.dart';

class PasswordRequirementWidget extends StatelessWidget {
  final String password;

  const PasswordRequirementWidget({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final has8Chars = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~^%()_\-+=]').hasMatch(password);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          _buildRuleChip('8+ chars', has8Chars),
          _buildRuleChip('Uppercase (A-Z)', hasUpper),
          _buildRuleChip('Lowercase (a-z)', hasLower),
          _buildRuleChip('Number (0-9)', hasNumber),
          _buildRuleChip('Special (!@#...)', hasSpecial),
        ],
      ),
    );
  }

  Widget _buildRuleChip(String label, bool isMet) {
    final color = isMet ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
