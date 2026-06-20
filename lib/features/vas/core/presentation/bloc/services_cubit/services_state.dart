import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:equatable/equatable.dart';

class ServicesState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<ServiceEntity> services;

  const ServicesState({
    this.isLoading = false,
    this.errorMessage,
    this.services = const [],
  });

  factory ServicesState.initial() => const ServicesState();

  ServicesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceEntity>? services,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      services: services ?? this.services,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, services];
}

extension ServicesDisplayExtension on ServicesState {
  /// Transforms the backend service list into a complete presentation list
  /// by dynamically appending localized custom actions.
  List<ServiceEntity> toDisplayList({bool includeMore = false}) {
    // 1. Define local-only constants inline
    const feePaymentService = ServiceEntity(
      id: 'fee_payment_local',
      name: 'Fee Payment',
      icon: 'assets/icons/feepayment.svg',
      type: ServiceType.feePayment,
      route: '/linked-students',
      isActive: true,
    );

    const fundingService = ServiceEntity(
      id: 'funding_local',
      name: 'Funding',
      icon: 'assets/icons/funding.svg',
      type: ServiceType.funding,
      route: '/fund-wallet',
      isActive: true,
    );

    const moreService = ServiceEntity(
      id: 'more_local',
      name: 'More',
      icon: 'assets/icons/more.svg',
      type: ServiceType.more,
      route: '/service',
      isActive: true,
    );

    if (services.isEmpty) {
      return includeMore
          ? [feePaymentService, fundingService, moreService]
          : [feePaymentService, fundingService];
    }

    // 2. Map backend items to sync layout presentation paths and naming schemas
    final backendServices = services.map((backendService) {
      final slug = backendService.slug?.trim().toUpperCase();

      String localName = backendService.name;
      String localIcon = 'assets/icons/default.svg';
      String localRoute = backendService.route;

      switch (slug) {
        case 'AIRTIME':
          localName = 'Airtime';
          localIcon = 'assets/icons/airtime.svg';
          localRoute = '/service/airtime';
          break;
        case 'DATA':
          localName = 'Internet';
          localIcon = 'assets/icons/data.svg';
          localRoute = '/service/data';
          break;
        case 'CABLETV':
          localName = 'Cable TV';
          localIcon = 'assets/icons/cable.svg';
          localRoute = '/service/cable-tv';
          break;
        case 'UTILITY':
          localName = 'Electricity';
          localIcon = 'assets/icons/elect.svg';
          localRoute = '/service/electricity';
          break;
      }

      return ServiceEntity(
        id: backendService.id,
        name: localName,
        icon: localIcon,
        type: backendService.type,
        route: localRoute,
        isActive: backendService.isActive,
        slug: backendService.slug,
      );
    }).toList();

    // 3. Assemble components uniformly based on lookahead flags
    return [
      feePaymentService,
      ...backendServices,
      fundingService,
      if (includeMore) moreService,
    ];
  }
}
