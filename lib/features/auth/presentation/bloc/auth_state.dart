import 'package:equatable/equatable.dart';
import '../../data/models/auth_response_model.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthResponseModel? authResponse;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.authResponse,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        authResponse = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        authResponse = null,
        errorMessage = null;

  const AuthState.authenticated(this.authResponse)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.otpSent()
      : status = AuthStatus.otpSent,
        authResponse = null,
        errorMessage = null;

  const AuthState.otpVerified()
      : status = AuthStatus.otpVerified,
        authResponse = null,
        errorMessage = null;

  const AuthState.passwordReset()
      : status = AuthStatus.passwordReset,
        authResponse = null,
        errorMessage = null;

  const AuthState.error(this.errorMessage)
      : status = AuthStatus.error,
        authResponse = null;

  @override
  List<Object?> get props => [status, authResponse, errorMessage];
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  otpSent,
  otpVerified,
  passwordReset,
  error,
}
