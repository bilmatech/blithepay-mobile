import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _copyFallback(urlString);
      }
    } catch (e) {
      _copyFallback(urlString);
    }
  }

  void _copyFallback(String urlString) {
    String textToCopy = urlString.split(':').last;
    if (textToCopy.contains('wa.me')) {
      textToCopy = '+2349017402116';
    }
    _copyToClipboard(textToCopy, 'Copied: $textToCopy');
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightBlueBg = AppColors.lightBack.withValues(alpha: 0.05);

    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactCard(
                icon: Icons.phone_rounded,
                title: 'Call Support',
                subtitle: '+234 901 740 2116',
                color: AppColors.primary,
                bgColor: lightBlueBg,
                onTap: () => _launchUrl('tel:+2349017402116'),
                onLongPress: () =>
                    _copyToClipboard('+2349017402116', 'Phone number copied to clipboard!'),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Chat on WhatsApp',
                subtitle: '+234 901 740 2116',
                color: const Color(0xFF25D366),
                bgColor: lightBlueBg,
                onTap: () => _launchUrl('https://wa.me/2349017402116'),
                onLongPress: () =>
                    _copyToClipboard('+2349017402116', 'WhatsApp number copied to clipboard!'),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@blithepay.com',
                color: Colors.purple.shade700,
                bgColor: lightBlueBg,
                onTap: () => _launchUrl('mailto:support@blithepay.com'),
                onLongPress: () =>
                    _copyToClipboard('support@blithepay.com', 'Email address copied to clipboard!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
          color: bgColor,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }
}
