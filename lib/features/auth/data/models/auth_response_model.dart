import 'package:blithepay/features/wallet/data/models/wallet_model.dart';
import 'package:equatable/equatable.dart';

class AuthResponseModel extends Equatable {
  final UserModel? user;
  final AuthTokensModel? tokens;
  final WalletModel? wallet;
  final String? message;

  const AuthResponseModel({this.user, this.tokens, this.wallet, this.message});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      tokens: json['tokens'] != null
          ? AuthTokensModel.fromJson(json['tokens'])
          : null,
      wallet: json['wallet'] != null
          ? WalletModel.fromJson(json['wallet'])
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user?.toJson(),
    'tokens': tokens?.toJson(),
  };

  @override
  List<Object?> get props => [user, tokens];
}

class AuthTokensModel {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthTokensModel({this.accessToken, this.refreshToken, this.expiresAt});

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt?.toIso8601String(),
  };
}

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? type;
  final String? accountStatus;
  final String? profileImage;
  final DateTime? verifiedAt;

  const UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.type,
    this.accountStatus,
    this.profileImage,
    this.verifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      type: json['type'],
      accountStatus: json['accountStatus'],
      profileImage: json['profileImage'] ?? json['picture'] ?? json['profile_image'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'type': type,
      'accountStatus': accountStatus,
    };
  }
}

class SignupUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String email;
  final String type;
  final String phone;
  final String accountStatus;
  final DateTime? verifiedAt;
  final DateTime? lastSeenAt;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SignupUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.email,
    required this.type,
    required this.phone,
    required this.accountStatus,
    required this.verifiedAt,
    required this.lastSeenAt,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SignupUserModel.fromJson(Map<String, dynamic> json) {
    return SignupUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profileImage: json['profileImage'] ?? json['picture'] ?? json['profile_image'],
      email: json['email'] as String,
      type: json['type'] as String,
      phone: json['phone'] as String,
      accountStatus: json['accountStatus'] as String,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'])
          : null,
      isDeleted: json['isDeleted'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CredentialModel {
  final String id;
  final String userId;
  final String token;
  final DateTime expiresAt;
  final bool revoked;
  final bool isDeleted;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String user;

  CredentialModel({
    required this.id,
    required this.userId,
    required this.token,
    required this.expiresAt,
    required this.revoked,
    required this.isDeleted,
    required this.updatedAt,
    required this.createdAt,
    required this.user,
  });

  factory CredentialModel.fromJson(Map<String, dynamic> json) {
    return CredentialModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt']),
      revoked: json['revoked'] as bool,
      isDeleted: json['isDeleted'] as bool,
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'revoked': revoked,
      'isDeleted': isDeleted,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'user': user,
    };
  }
}
