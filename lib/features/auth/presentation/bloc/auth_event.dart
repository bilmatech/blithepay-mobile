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
  final OtpFlow flow;

  const VerifyOtpRequested({
    required this.email,
    required this.code,
    required this.flow,
  });
  @override
  List<Object?> get props => [email, code];
}

class VerifyForgotPasswordOtpRequested extends AuthEvent {
  final String email;
  final String code;
  final OtpFlow flow;

  const VerifyForgotPasswordOtpRequested({
    required this.email,
    required this.code,
    required this.flow,
  });
  @override
  List<Object?> get props => [email, code];
}

class SetupPinRequested extends AuthEvent {
  final String email;
  final String code;
  final OtpFlow flow;

  const SetupPinRequested({
    required this.email,
    required this.code,
    required this.flow,
  });

  @override
  List<Object?> get props => [email, code];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, newPassword, confirmPassword];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class AppleSignInRequested extends AuthEvent {
  const AppleSignInRequested();
}

enum OtpFlow { signup, forgotPassword, verifyEmail }

class SignupPayload extends Equatable {
  final String userId;
  final String email;
  //final String? tempToken;

  const SignupPayload({
    required this.userId,
    required this.email,
    // this.tempToken,
  });

  @override
  List<Object?> get props => [userId, email];
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  final OtpFlow flow;

  const ResendOtpRequested({required this.email, required this.flow});
}

class ResendForgotPasswordOtpRequested extends AuthEvent {
  final String email;
  final OtpFlow flow;

  const ResendForgotPasswordOtpRequested({
    required this.email,
    required this.flow,
  });
}
