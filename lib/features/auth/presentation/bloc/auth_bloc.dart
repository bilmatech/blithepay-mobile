import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;

  AuthBloc({required AuthRepositoryInterface authRepository})
    : _authRepository = authRepository,
      super(const AuthState.initial()) {
    on<SignupRequested>(_onSignupRequested);
    on<LoginRequested>(_onLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      // final result = await _authRepository.signup(
      //   event.email,
      //   event.password,
      //   event.fullName,
      //   event.phoneNumber,
      // );
      emit(const AuthState.authenticated(AuthResponseModel()));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final result = await _authRepository.login(event.email, event.password);
      emit(AuthState.authenticated(result));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      // await _authRepository.forgotPassword(event.email);
      emit(const AuthState.otpSent());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      // await _authRepository.verifyOtp(event.email, event.code);
      emit(const AuthState.otpVerified());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      // await _authRepository.resetPassword(
      //   event.email,
      //   event.newPassword,
      //   event.confirmPassword,
      // );
      emit(const AuthState.passwordReset());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
     // await _authRepository.logout();
      emit(const AuthState.initial());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
