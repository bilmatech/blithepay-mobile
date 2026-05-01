import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/layouts/app_card.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingBase),
        child: Column(
          children: [
            const HeadingLg(
              "Services",
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const VSpaceBase(),
            _buildServicesGrid(context),
          ],
        ),
      ),
    );
  }
}

Widget _buildServicesGrid(BuildContext context) {
  final services = [
    ('Airtime', Icons.phone_android, AppRoutes.airtimeService),
    ('Data', Icons.wifi, AppRoutes.dataService),
    ('Cable/TV', Icons.tv, AppRoutes.cableTvService),
    ('Electricity', Icons.flash_on, AppRoutes.electricityService),
  ];

  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: AppSpacing.lg,
    mainAxisSpacing: AppSpacing.lg,
    childAspectRatio: 1.15,
    children: services
        .map((service) => _buildServiceCard(context, service.$1, service.$2, service.$3))
        .toList(),
  );
}

Widget _buildServiceCard(BuildContext context, String name, IconData icon, String route) {
  return AppCard(
    backgroundColor: AppColors.surfaceOrange,
    onTap: () => GoRouter.of(context).push(route),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: AppSpacing.xhuge,
          height: AppSpacing.xhuge,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSpacing.iconXl),
        ),
        const VSpaceBase(),
        BodyMd(name, color: AppColors.textPrimary, textAlign: TextAlign.center),
      ],
    ),
  );
}
