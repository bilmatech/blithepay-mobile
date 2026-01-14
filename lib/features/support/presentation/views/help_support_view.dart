import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How Do Parents Link Their Children On The App?',
      'answer':
          'A parent searches using the admission number, enters a verifying code, and confirms phone number matching. Unauthorized access is blocked automatically.',
    },
    {
      'question': 'Can Schools Accept Offline Payments Too?',
      'answer':
          'Yes, schools can configure offline payment options in their dashboard.',
    },
    {
      'question': 'How Does Blithes Ensure Data Security?',
      'answer':
          'We use industry-standard encryption and regular security audits.',
    },
    {
      'question': 'Does The System Support Multiple Payment Methods?',
      'answer': 'Yes, including card, bank transfer, and wallet balance.',
    },
    {
      'question': 'What If A Parent Enters Incorrect Details?',
      'answer': 'The system will show an error message and allow retry.',
    },
    {
      'question': 'How Much Does Blithes Cost?',
      'answer':
          'Pricing varies based on school size and features. Contact sales for details.',
    },
  ];

  List<bool> _expandedFaqs = [];

  @override
  void initState() {
    super.initState();
    _expandedFaqs = List.generate(faqs.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Support Form
              Text(
                'Contact Support:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              const AppTextField(label: 'Your Name', hint: 'Type here'),
              const SizedBox(height: 12),
              const AppTextField(label: 'Email', hint: '@gmail.com'),
              const SizedBox(height: 12),
              const AppTextField(
                label: 'Your Message',
                hint: 'Type here',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Send Message', onPressed: () {}),
              const SizedBox(height: 24),

              // Contact Information
              Text(
                'Contact Information:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.headset_mic,
                title: 'Contact Live Support',
                subtitle: 'Available 24/7',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: '+2347098784567',
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.event,
                title: 'Book A Demo',
                subtitle: '1 on 1 call with a member of our team',
              ),
              const SizedBox(height: 24),

              // FAQs
              Text(
                'Frequently Asked Questions:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              ...List.generate(faqs.length, (index) {
                return GestureDetector(
                  onTap: () => setState(
                    () => _expandedFaqs[index] = !_expandedFaqs[index],
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  faqs[index]['question']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Icon(
                                _expandedFaqs[index]
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        if (_expandedFaqs[index])
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.borderColor),
                              ),
                            ),
                            child: Text(
                              faqs[index]['answer']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.lightBackground,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
