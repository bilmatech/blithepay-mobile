import 'package:blithepay/features/vas/core/data/models/service_model.dart';
import 'package:equatable/equatable.dart';

enum ServiceType {
  airtime,
  data,
  electricity,
  cableTv,
  feePayment,
  funding,
  more,
}

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final ServiceType type;
  final String route;
  final bool isActive;
  final String? slug;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.route,
    required this.isActive,
    this.slug,
  });

  static ServiceEntity? fromApiServiceModel(ServiceModel model) {
    final slug = model.slug.trim().toUpperCase();
    switch (slug) {
      case 'AIRTIME':
        return ServiceEntity(
          id: model.id,
          name: model.name,
          icon: 'assets/icons/airtime.svg',
          type: ServiceType.airtime,
          route: '/service/airtime',
          isActive: true,
          slug: slug,
        );
      case 'DATA':
        return ServiceEntity(
          id: model.id,
          name: model.name,
          icon: 'assets/icons/data.svg',
          type: ServiceType.data,
          route: '/service/data',
          isActive: true,
          slug: slug,
        );
      case 'CABLETV':
        return ServiceEntity(
          id: model.id,
          name: model.name,
          icon: 'assets/icons/cable.svg',
          type: ServiceType.cableTv,
          route: '/service/cable-tv',
          isActive: true,
          slug: slug,
        );
      case 'UTILITY':
        return ServiceEntity(
          id: model.id,
          name: model.name,
          icon: 'assets/icons/elect.svg',
          type: ServiceType.electricity,
          route: '/service/electricity',
          isActive: true,
          slug: slug,
        );
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [id, name, icon, type, route, isActive, slug];
}
