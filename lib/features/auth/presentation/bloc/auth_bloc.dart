import 'auth_event.dart';
import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/core/services/firebase_auth_service.dart';
import 'package:blithepay/core/services/firebase_notifications.dart';
import 'package:blithepay/core/services/biometric_crypto_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

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
    on<InitiatePinResetRequested>(_onInitiatePinResetRequested);
    on<FinalizePinResetRequested>(_onFinalizePinResetRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
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
    emit(state.copyWith(status: AuthStatus.loading, loadingType: LoadingType.email));
    try {
      final result = await _authRepository.login(event.email, event.password);

      if (result.user?.verifiedAt == null) {
        emit(AuthState.error(result.message ?? 'Your account is not verified'));
        return;
      }

      // Persist session
      await _authRepository.persistSession(result);

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

  Future<void> _onInitiatePinResetRequested(
    InitiatePinResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.initiatePinReset();
      emit(const AuthState.pinResetInitiated());
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onFinalizePinResetRequested(
    FinalizePinResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.resetPin(
        verificationCode: event.verificationCode,
        newPin: event.newPin,
      );
      emit(const AuthState.pinResetSuccess());
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

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, loadingType: LoadingType.google));
    try {
      final userCredential = await _firebaseAuthService.signInWithGoogle();

      if (userCredential?.user == null) {
        emit(const AuthState.error('Google sign-in failed.'));
        return;
      }

      final idToken = await userCredential!.user!.getIdToken();
      if (idToken == null) {
        emit(const AuthState.error('Failed to retrieve Firebase ID Token.'));
        return;
      }

      final result = await _authRepository.authenticateSso(idToken);

      // Persist session
      await _authRepository.persistSession(result);

      emit(AuthState.authenticated(result));
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }

  Future<void> _onAppleSignInRequested(AppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, loadingType: LoadingType.apple));
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);

      if (userCredential.user == null) {
        emit(const AuthState.error('Apple sign-in failed.'));
        return;
      }

      final idToken = await userCredential.user!.getIdToken();
      if (idToken == null) {
        emit(const AuthState.error('Failed to retrieve Firebase ID Token.'));
        return;
      }

      final result = await _authRepository.authenticateSso(idToken);
      await _authRepository.persistSession(result);

      emit(AuthState.authenticated(result));
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }
  // Future<void> _onAppleSignInRequested(
  //   AppleSignInRequested event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(
  //     state.copyWith(
  //       status: AuthStatus.loading,
  //       loadingType: LoadingType.apple,
  //     ),
  //   );
  //   try {
  //     final userCredential = await _firebaseAuthService.signInWithApple();

  //     if (userCredential.user == null) {
  //       emit(const AuthState.error('Apple sign-in failed.'));
  //       return;
  //     }

  //     final idToken = await userCredential.user!.getIdToken();
  //     if (idToken == null) {
  //       emit(const AuthState.error('Failed to retrieve Firebase ID Token.'));
  //       return;
  //     }

  //     final result = await _authRepository.authenticateSso(idToken);

  //     // Persist session
  //     await _authRepository.persistSession(result);

  //     emit(AuthState.authenticated(result));
  //   } catch (e) {
  //     emit(AuthState.error(extractError(e)));
  //   }
  // }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, loadingType: LoadingType.biometric));
    try {
      // 1. Get single-use challenge from NestJS backend
      final challenge = await _authRepository.getBiometricChallenge(
        email: event.email,
        deviceId: event.deviceId,
      );

      // 2. Request signature of challenge from native hardware
      final signature = await BiometricCryptoService.signChallenge(challenge);
      if (signature == null || signature.isEmpty) {
        emit(const AuthState.error('Biometric authentication cancelled or failed.'));
        return;
      }

      // 3. Verify signature and log in against NestJS backend
      final result = await _authRepository.verifyBiometrics(
        email: event.email,
        deviceId: event.deviceId,
        challenge: challenge,
        signatureBase64: signature,
      );

      // 4. Persist user session locally
      await _authRepository.persistSession(result);

      emit(AuthState.authenticated(result));
    } catch (e) {
      emit(AuthState.error(extractError(e)));
    }
  }
}
