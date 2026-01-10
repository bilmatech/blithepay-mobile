import 'package:equatable/equatable.dart';

class AuthResponseModel extends Equatable {
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final String? message;

  const AuthResponseModel({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'refresh_token': refreshToken,
        'user': user?.toJson(),
        'message': message,
      };

  @override
  List<Object?> get props => [token, refreshToken, user, message];
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.emailVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      emailVerified: json['email_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email_verified': emailVerified,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, email, fullName, phoneNumber, emailVerified, createdAt];
}
