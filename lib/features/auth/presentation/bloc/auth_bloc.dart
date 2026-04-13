import 'auth_event.dart';
import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/services/firebase_notifications.dart';

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

  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    try {
      final fcmToken = await getFcmToken();

      final result = await _authRepository.signup(
        event.email,
        event.password,
        event.fullName,
        event.phoneNumber,
        fcmToken,
      );

      emit(
        AuthState.signupSuccess(SignupPayload(userId: result.id ?? '', email: result.email ?? '')),
      );
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<String> getFcmToken() async {
    try {
      final firebaseNotifications = FirebaseNotifications();
      return await firebaseNotifications.getFcmToken();
    } catch (e) {
      return '';
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    try {
      final result = await _authRepository.login(event.email, event.password);

      if (result.user?.verifiedAt == null) {
        emit(AuthState.error(result.message ?? 'Your account is not verified'));
        return;
      }

      // Persist session
      await _authRepository.persistSession(result);

      // Sync FCM token on login to handle device changes
      final fcmToken = await getFcmToken();
      if (fcmToken.isNotEmpty) {
        await _authRepository.syncFcmToken(fcmToken);
      }

      emit(AuthState.authenticated(result));
    } catch (e) {
      emit(AuthState.error(extractError(e)));
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
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      var result = await _authRepository.verifyOtp(event.code);
      emit(const AuthState.otpVerified());

      await _authRepository.persistSession(result);
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onResendOtpRequested(ResendOtpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.resendOtp(event.email);
      emit(const AuthState.otpSent());
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onSetupPinRequested(SetupPinRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.setupPin(event.email, event.code);
      emit(const AuthState.pinSetup());
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onVerifyForgotPasswordOtpRequested(
    VerifyForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      var result = await _authRepository.verifyForgotPasswordOtp(event.code);
      emit(AuthState.otpVerified(token: result));
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.resetPassword(event.token, event.newPassword);

      emit(const AuthState.passwordReset());
    } catch (e) {
      emit(AuthState.error(extractError(e)));
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
      emit(AuthState.error(extractError(e)));
    }
  }
}
