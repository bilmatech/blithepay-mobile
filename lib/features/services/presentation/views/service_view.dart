import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/service_card.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:blithepay/shared/widgets/layouts/app_card.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filteredServices = services.where((s) => s.name != 'More').toList();

    return AppScaffold(
      appBar: const AppAppBar(title: 'Services', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingBase),
        child: GridView.builder(
          itemCount: filteredServices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 6,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final service = filteredServices[index];

            return ServiceCard(
              service: service,
              onTap: () {
                context.push(service.route);
              },
            );
          },
        ),
      ),
    );
  }
}

Widget _buildServicesGrid(BuildContext context) {
  return GridView.builder(
    shrinkWrap: true,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.2,
    ),
    itemCount: services.length - 2,
    itemBuilder: (context, index) {
      final service = services[index];
      return _buildServiceCard(
        context,
        service.name,
        service.icon,
        service.route,
      );
    },
  );
}

Widget _buildServiceCard(
  BuildContext context,
  String name,
  String icon,
  String route,
) {
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
          child: SvgPicture.asset(icon),
        ),
        const VSpaceBase(),
        BodyMd(name, color: AppColors.textPrimary, textAlign: TextAlign.center),
      ],
    ),
  );
}
