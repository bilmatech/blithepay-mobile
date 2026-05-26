import 'package:equatable/equatable.dart';

enum ServiceType { airtime, data, electricity, cableTv, feePayment, funding, more }

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final ServiceType type;
  final String route;
  final bool isActive;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.route,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, icon, type, route, isActive];
}

var services = [
  const ServiceEntity(
    id: '1',
    name: 'Fee Payment',
    icon: 'assets/icons/feepayment.svg',
    type: ServiceType.feePayment,
    route: '/linked-students',
    isActive: true,
  ),
  const ServiceEntity(
    id: '2',
    name: 'Airtime',
    icon: 'assets/icons/airtime.svg',
    type: ServiceType.airtime,
    route: '/service/airtime',
    isActive: true,
  ),
  const ServiceEntity(
    id: '3',
    name: 'Internet',
    icon: 'assets/icons/data.svg',
    type: ServiceType.data,
    route: '/service/data',
    isActive: true,
  ),
  const ServiceEntity(
    id: '4',
    name: 'Cable TV',
    icon: 'assets/icons/cable.svg',
    type: ServiceType.cableTv,
    route: '/service/cable-tv',
    isActive: true,
  ),
  const ServiceEntity(
    id: '5',
    name: 'Electricity',
    icon: 'assets/icons/elect.svg',
    type: ServiceType.electricity,
    route: '/service/electricity',
    isActive: true,
  ),
  const ServiceEntity(
    id: '7',
    name: 'Funding',
    icon: 'assets/icons/funding.svg',
    type: ServiceType.funding,
    route: '/fund-wallet',
    isActive: true,
  ),
  const ServiceEntity(
    id: '8',
    name: 'More',
    icon: 'assets/icons/more.svg',
    type: ServiceType.more,
    route: '/service',
    isActive: true,
  ),
  // Add more services as needed
];
