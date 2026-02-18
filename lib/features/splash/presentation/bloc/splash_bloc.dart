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

    final onboardingCompleted = await authRepository.isOnboardingCompleted();
    final session = await authRepository.getSession();

    if (!onboardingCompleted) {
      emit(SplashNavigateOnboarding());
    } else if (session != null && session.tokens != null) {
      emit(SplashNavigateDashboard());
    } else {
      emit(SplashNavigateLogin());
    }
  }
}