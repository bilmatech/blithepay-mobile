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
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<VerifyForgotPasswordOtpRequested>(_onVerifyForgotPasswordOtpRequested);
    on<ResendForgotPasswordOtpRequested>(_onResendForgotPasswordOtpRequested);
    on<SetupPinRequested>(_onSetupPinRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final result = await _authRepository.signup(
        event.email,
        event.password,
        event.fullName,
        event.phoneNumber,
      );
      emit(
        AuthState.signupSuccess(
          SignupPayload(userId: result.id ?? '', email: result.email ?? ''),
        ),
      );
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
      await _authRepository.persistSession(result);
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
      await _authRepository.forgotPassword(event.email);
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
      var result = await _authRepository.verifyOtp(event.code);
      emit(const AuthState.otpVerified());

      await _authRepository.persistSession(result);
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.resendOtp(event.email);
      emit(const AuthState.otpSent());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSetupPinRequested(
    SetupPinRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.setupPin(event.email, event.code);
      emit(const AuthState.pinSetup());
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
      await _authRepository.resetPassword(event.newPassword);
      
      emit(const AuthState.passwordReset());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onVerifyForgotPasswordOtpRequested(
    VerifyForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      var result = await _authRepository.verifyOtp(event.code);
      emit(const AuthState.otpVerified());

      await _authRepository.persistSession(result);
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onResendForgotPasswordOtpRequested(
    ResendForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.resendOtp(event.email);
      emit(const AuthState.otpSent());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
