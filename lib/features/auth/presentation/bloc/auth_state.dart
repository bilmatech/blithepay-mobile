import 'package:equatable/equatable.dart';
import '../../data/models/auth_response_model.dart';
import 'package:blithepay/features/auth/presentation/bloc/auth_event.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthResponseModel? authResponse;
  final SignupPayload? signupResponse;
  final String? token;
  final LoadingType loadingType;

  final String? errorMessage;

  const AuthState({
    required this.status,
    this.authResponse,
    this.signupResponse,
    this.errorMessage,
    this.token,
    this.loadingType = LoadingType.none,
  });
  const AuthState.initial()
    : status = AuthStatus.initial,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.loading()
    : status = AuthStatus.loading,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.signupSuccess(this.signupResponse)
    : status = AuthStatus.signupSuccess,
      errorMessage = null,
      authResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.authenticated(this.authResponse)
    : status = AuthStatus.authenticated,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.otpSent()
    : status = AuthStatus.otpSent,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.otpVerified({this.token})
    : status = AuthStatus.otpVerified,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      loadingType = LoadingType.none;

  const AuthState.pinSetup()
    : status = AuthStatus.pinSetup,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.pinResetInitiated()
    : status = AuthStatus.pinResetInitiated,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.pinResetSuccess()
    : status = AuthStatus.pinResetSuccess,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.passwordReset()
    : status = AuthStatus.passwordReset,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  const AuthState.error(this.errorMessage)
    : status = AuthStatus.error,
      authResponse = null,
      signupResponse = null,
      token = null,
      loadingType = LoadingType.none;

  @override
  List<Object?> get props => [
    status,
    authResponse,
    signupResponse,
    errorMessage,
    token,
    loadingType,
  ];

  AuthState copyWith({
    AuthStatus? status,
    LoadingType? loadingType,
    String? errorMessage,
    AuthResponseModel? authResponse,
    SignupPayload? signupResponse,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      loadingType: loadingType ?? this.loadingType,
      errorMessage: errorMessage ?? this.errorMessage,
      authResponse: authResponse,
      signupResponse: signupResponse,
      token: token,
    );
  }
}

enum AuthStatus {
  initial,
  loading,
  signupSuccess,
  authenticated,
  otpSent,
  otpVerified,
  pinSetup,
  pinResetInitiated,
  pinResetSuccess,
  passwordReset,
  error,
}

enum LoadingType { none, email, google, apple, biometric }
