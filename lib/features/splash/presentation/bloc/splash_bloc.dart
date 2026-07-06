import 'package:blithepay/core/services/session_timeout_manager.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository authRepository;

  SplashBloc({required this.authRepository}) : super(SplashInitial()) {
    on<CheckSplashStatus>(_onCheckSplashStatus);
  }

  Future<void> _onCheckSplashStatus(
      CheckSplashStatus event, Emitter<SplashState> emit) async {
    await Future.delayed(const Duration(seconds: 3));

    // Clear session on fresh boot to satisfy "or the user closes the app"
    if (AppLifecycleManager.isFreshBoot) {
      AppLifecycleManager.isFreshBoot = false;
      await authRepository.clearSession();
      await authRepository.clearLastActiveTime();
    }

    final onboardingCompleted = await authRepository.isOnboardingCompleted();
    final session = await authRepository.getSession();
    final biometricsEnabled = await authRepository.isBiometricsEnabled();
    final biometricEmail = await authRepository.getBiometricEmail();

    if (!onboardingCompleted) {
      emit(SplashNavigateOnboarding());
    } else if (session != null && session.tokens != null) {
      emit(SplashNavigateDashboard());
    } else if (biometricsEnabled && biometricEmail != null && biometricEmail.isNotEmpty) {
      emit(SplashNavigateBiometric());
    } else {
      emit(SplashNavigateLogin());
    }
  }
}