import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
import 'package:blithepay/features/services/presentation/bloc/services_cubit/services_state.dart';
import 'package:blithepay/features/services/data/models/service_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServiceRepository _serviceRepository;

  ServicesCubit({required ServiceRepository serviceRepository})
    : _serviceRepository = serviceRepository,
      super(ServicesState.initial()) {
    loadServices();
  }

  Future<void> loadServices() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final remoteServices = await _serviceRepository.getServices();
      final mappedServices = remoteServices
          .map(ServiceEntity.fromApiServiceModel)
          .whereType<ServiceEntity>()
          .toList();

      emit(state.copyWith(isLoading: false, services: mappedServices));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
