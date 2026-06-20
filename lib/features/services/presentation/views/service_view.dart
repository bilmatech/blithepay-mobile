import 'package:blithepay/core/constants/app_spacing.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/service_card.dart';
import 'package:blithepay/features/services/presentation/bloc/services_cubit/services_cubit.dart';
import 'package:blithepay/features/services/presentation/bloc/services_cubit/services_state.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        if (state.isLoading && state.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredServices = state.toDisplayList(includeMore: false);

        return AppScaffold(
          appBar: const AppAppBar(title: 'Services', showBackButton: false),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingBase),
            child: filteredServices.isEmpty
                ? const Center(child: Text('No services available'))
                : GridView.builder(
                    itemCount: filteredServices.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          context.push(service.route, extra: service);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
