import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String? avatarUrl;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: .15),
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
          child: avatarUrl == null || avatarUrl!.isEmpty
              ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(userName, style: AppTextStyles.headingSmall),
          ],
        ),
        // const Spacer(),
        // IconButton(
        //   icon: const Icon(Icons.notifications_none),
        //   onPressed: () {
        //     context.push(AppRoutes.notifications);
        //   },
        // ),
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: AppColors.surface,
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: const Icon(Icons.notifications_none, color: AppColors.primary),
        // ),
      ],
    );
  }
}
