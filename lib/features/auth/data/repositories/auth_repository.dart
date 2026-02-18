import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/core/storage/hive_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRepositoryInterface {
  Future<UserModel> signup(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    String fcmtoken,
  );
  Future<AuthResponseModel> login(String email, String password);
  Future<void> forgotPassword(String email);
  Future<AuthResponseModel> verifyOtp(String code);
  Future<String> verifyForgotPasswordOtp(String code);

  Future<AuthResponseModel> resendOtp(String email);
  Future<AuthResponseModel> resendForgotPasswordOtp(String email);

  Future<void> setupPin(String email, String code);
  Future<void> resetPassword(String resetToken, String newPassword);
  Future<void> logout();
  Future<void> persistSession(AuthResponseModel session);
  Future<AuthTokensModel> refresh(String token);

  Future<AuthResponseModel?> getSession();
  Future<bool> isOnboardingCompleted();
  Future<void> syncFcmToken(String token);
}

class AuthRepository implements AuthRepositoryInterface {
  final DioClient _dioClient;
  final AppLocalDataSource _localDataSource;

  AuthRepository({
    required DioClient dioClient,
    required AppLocalDataSource localDataSource,
  }) : _dioClient = dioClient,
       _localDataSource = localDataSource;

  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  final HiveService hive = HiveService();

  @override
  Future<UserModel> signup(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    String fcmtoken,
  ) async {
    final response = await _dioClient.post(
      ApiEndpoints.signup,
      data: {
        "fullName": fullName,
        "email": email,
        "phone": phoneNumber,
        "isTermsAndPrivacyAccepted": true,
        "password": password,
        "fcmToken": fcmtoken,
      },
    );
    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    return AuthResponseModel.fromJson(
      (await _dioClient.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password, "source": 'mobile'},
      )).data['data'],
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  @override
  Future<AuthResponseModel> verifyOtp(String code) async {
    var response = await _dioClient.post(
      ApiEndpoints.verifyOtp,
      data: {"code": code},
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthResponseModel> resendOtp(String email) async {
    var response = await _dioClient.post(
      ApiEndpoints.resendOtp,
      data: {'email': email},
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<String> verifyForgotPasswordOtp(String code) async {
    var response = await _dioClient.post(
      ApiEndpoints.verifyForgotPasswordCode,
      data: {"code": code},
    );

    return response.data['data'];
  }

  @override
  Future<AuthResponseModel> resendForgotPasswordOtp(String email) async {
    var response = await _dioClient.post(
      ApiEndpoints.resendForgotPasswordCode,
      data: {'email': email},
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> setupPin(String email, String code) async {
    await _dioClient.post(ApiEndpoints.setupPin, data: {"pin": code});
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    // if (resetToken.isEmpty) {
    //   throw Exception('Reset token not found');
    // }

    await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: {'token': resetToken, 'newPassword': newPassword},
    );
  }

  @override
  Future<void> logout() async {
    await _dioClient.post(ApiEndpoints.logout);
  }

  @override
  Future<void> persistSession(AuthResponseModel session) async {
    await _localDataSource.saveTokens(session.tokens!);
    await _localDataSource.saveSession(session);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return await _localDataSource.isOnboardingCompleted();
  }

  @override
  Future<AuthResponseModel?> getSession() async {
    return await _localDataSource.getSession();
  }

  @override
  Future<AuthTokensModel> refresh(String token) async {
    final response = await _dioClient.post(
      ApiEndpoints.refreshToken,
      data: {'token': token},
    );
    return AuthTokensModel.fromJson(response.data['data']);
  }

  @override
  Future<void> syncFcmToken(String token) async {
    await _dioClient.post(ApiEndpoints.synToken, data: {'token': token});
  }
}

class TokenRefreshResponse {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  TokenRefreshResponse({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      userId: json['userId'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}
