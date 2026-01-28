import 'package:blithepay/features/auth/presentation/bloc/auth_event.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/auth_response_model.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthResponseModel? authResponse;
  final SignupPayload? signupResponse;
  final String? token;

  final String? errorMessage;

  const AuthState({
    required this.status,
    this.authResponse,
    this.signupResponse,
    this.errorMessage,
    this.token,
  });
  const AuthState.initial()
    : status = AuthStatus.initial,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null;

  const AuthState.signupSuccess(this.signupResponse)
    : status = AuthStatus.signupSuccess,
      errorMessage = null,
      authResponse = null,
      token = null;

  const AuthState.authenticated(this.authResponse)
    : status = AuthStatus.authenticated,
      errorMessage = null,
      signupResponse = null,
      token = null;

  const AuthState.otpSent()
    : status = AuthStatus.otpSent,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null;

  const AuthState.otpVerified({this.token})
    : status = AuthStatus.otpVerified,
      authResponse = null,
      errorMessage = null,
      signupResponse = null;

  const AuthState.pinSetup()
    : status = AuthStatus.pinSetup,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null;

  const AuthState.passwordReset()
    : status = AuthStatus.passwordReset,
      authResponse = null,
      errorMessage = null,
      signupResponse = null,
      token = null;

  const AuthState.error(this.errorMessage)
    : status = AuthStatus.error,
      authResponse = null,
      signupResponse = null,
      token = null;

  @override
  List<Object?> get props => [
    status,
    authResponse,
    signupResponse,
    errorMessage,
  ];
}

enum AuthStatus {
  initial,
  loading,
  signupSuccess,
  authenticated,
  otpSent,
  otpVerified,
  pinSetup,
  passwordReset,
  error,
}
