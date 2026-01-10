import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;

  const SignupRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String code;

  const VerifyOtpRequested({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, newPassword, confirmPassword];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
