import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import '../models/auth_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:blithepay/core/storage/hive_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRepositoryInterface {
  Future<UserModel> signup(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    String fcmtoken,
  );
  Future<AuthResponseModel> login(
    String email,
    String password, {
    String? deviceId,
    String? fcmToken,
  });
  Future<void> forgotPassword(String email);
  Future<AuthResponseModel> verifyOtp(String code);
  Future<String> verifyForgotPasswordOtp(String code);

  Future<AuthResponseModel> resendOtp(String email);
  Future<AuthResponseModel> resendForgotPasswordOtp(String email);

  Future<void> setupPin(String email, String code);
  Future<void> initiatePinReset();
  Future<void> resetPin({required String verificationCode, required String newPin});
  Future<void> resetPassword(String resetToken, String newPassword);
  Future<void> logout();
  Future<void> persistSession(AuthResponseModel session);
  Future<AuthTokensModel> refresh(String token);
  Future<void> clearSession();
  Future<void> saveLastActiveTime(DateTime time);
  Future<DateTime?> getLastActiveTime();
  Future<void> clearLastActiveTime();

  Future<AuthResponseModel?> getSession();
  Future<bool> isOnboardingCompleted();
  Future<bool> isBiometricsEnabled();
  Future<String?> getBiometricEmail();
  Future<void> setDontShowBiometricPrompt(bool value);
  Future<bool> getDontShowBiometricPrompt();
  Future<void> saveSavedEmail(String email);
  Future<String?> getSavedEmail();
  Future<void> clearSavedEmail();

  Future<void> deleteAccount();
  Future<UserModel> updateAccount({String? fullName, String? phone, String? picture});
  Future<AuthResponseModel> authenticateSso(
    String firebaseIdToken, {
    String? deviceId,
    String? fcmToken,
  });
  Future<void> changeAppPin(String oldPin, String newPin, String password);
  Future<String> getBiometricChallenge({required String email, required String deviceId});
  Future<String> enrollBiometric({
    required String email,
    required String deviceId,
    required String publicKey,
  });
  Future<AuthResponseModel> verifyBiometrics({
    required String email,
    required String deviceId,
    required String challenge,
    required String signatureBase64,
  });
}

class AuthRepository implements AuthRepositoryInterface {
  final DioClient _dioClient;
  final AppLocalDataSource _localDataSource;

  AuthRepository({required DioClient dioClient, required AppLocalDataSource localDataSource})
    : _dioClient = dioClient,
      _localDataSource = localDataSource;

  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  final HiveService hive = HiveService();

  Future<Map<String, dynamic>> _buildDeviceObject(String fcmToken) async {
    final deviceId = await _localDataSource.getOrCreateDeviceId();
    final effectiveFcmToken = fcmToken.isNotEmpty
        ? fcmToken
        : (await FirebaseMessaging.instance.getToken() ?? '');

    String platform = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');
    String deviceName = 'Unknown Device';
    String osVersion = 'Unknown OS';
    String appVersion = '1.0.0';
    String buildNumber = '1';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (_) {}

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name.isNotEmpty ? iosInfo.name : iosInfo.model;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }
    } catch (_) {}

    return {
      "deviceId": deviceId,
      "platform": platform,
      "deviceName": deviceName,
      "osVersion": osVersion,
      "appVersion": appVersion,
      "buildNumber": buildNumber,
      "fcmToken": effectiveFcmToken,
    };
  }

  @override
  Future<UserModel> signup(
    String email,
    String password,
    String fullName,
    String phoneNumber,
    String fcmtoken,
  ) async {
    final deviceObject = await _buildDeviceObject(fcmtoken);

    final response = await _dioClient.post(
      ApiEndpoints.signup,
      data: {
        "fullName": fullName,
        "email": email,
        "phone": phoneNumber,
        "isTermsAndPrivacyAccepted": true,
        "password": password,
        "device": deviceObject,
      },
    );
    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthResponseModel> login(
    String email,
    String password, {
    String? deviceId,
    String? fcmToken,
  }) async {
    final effectiveDeviceId = deviceId ?? await _localDataSource.getOrCreateDeviceId();
    final effectiveFcmToken = fcmToken ?? (await FirebaseMessaging.instance.getToken() ?? '');

    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {
        "email": email,
        "password": password,
        "source": 'mobile',
        "deviceId": effectiveDeviceId,
        "fcmToken": effectiveFcmToken,
      },
    );
    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  @override
  Future<AuthResponseModel> verifyOtp(String code) async {
    var response = await _dioClient.post(ApiEndpoints.verifyOtp, data: {"code": code});

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthResponseModel> resendOtp(String email) async {
    var response = await _dioClient.post(ApiEndpoints.resendOtp, data: {'email': email});

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
  Future<void> initiatePinReset() async {
    final response = await _dioClient.post(ApiEndpoints.pinInitiateReset);
    if (response.data == null || response.data['status'] != true) {
      final message = response.data?['message'] ?? 'Failed to initiate PIN reset';
      throw Exception(message);
    }
  }

  @override
  Future<void> resetPin({required String verificationCode, required String newPin}) async {
    final response = await _dioClient.patch(
      ApiEndpoints.pinReset,
      data: {'verificationCode': verificationCode, 'newPin': newPin},
    );
    if (response.data == null || response.data['status'] != true) {
      final message = response.data?['message'] ?? 'Failed to reset PIN';
      throw Exception(message);
    }
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
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await _localDataSource.clearSession();
    await _localDataSource.clearLastActiveTime();
  }

  @override
  Future<void> clearSession() async {
    await _localDataSource.clearSession();
  }

  @override
  Future<void> saveLastActiveTime(DateTime time) async {
    await _localDataSource.saveLastActiveTime(time);
  }

  @override
  Future<DateTime?> getLastActiveTime() async {
    return await _localDataSource.getLastActiveTime();
  }

  @override
  Future<void> clearLastActiveTime() async {
    await _localDataSource.clearLastActiveTime();
  }

  @override
  Future<void> persistSession(AuthResponseModel session) async {
    await _localDataSource.saveTokens(session.tokens!);
    await _localDataSource.saveSession(session);
    if (session.user?.email != null) {
      await _localDataSource.saveSavedEmail(session.user!.email!);
    }
  }

  @override
  Future<void> saveSavedEmail(String email) async {
    await _localDataSource.saveSavedEmail(email);
  }

  @override
  Future<String?> getSavedEmail() async {
    return await _localDataSource.getSavedEmail();
  }

  @override
  Future<void> clearSavedEmail() async {
    await _localDataSource.clearSavedEmail();
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return await _localDataSource.isOnboardingCompleted();
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    return await _localDataSource.isBiometricsEnabled();
  }

  @override
  Future<String?> getBiometricEmail() async {
    return await _localDataSource.getBiometricEmail();
  }

  @override
  Future<void> setDontShowBiometricPrompt(bool value) async {
    await _localDataSource.setDontShowBiometricPrompt(value);
  }

  @override
  Future<bool> getDontShowBiometricPrompt() async {
    return await _localDataSource.getDontShowBiometricPrompt();
  }

  @override
  Future<AuthResponseModel?> getSession() async {
    return await _localDataSource.getSession();
  }

  @override
  Future<AuthTokensModel> refresh(String token) async {
    final response = await _dioClient.post(ApiEndpoints.refreshToken, data: {'token': token});
    return AuthTokensModel.fromJson(response.data['data']);
  }

  Future<String> uploadImage(File picture, String folder) async {
    try {
      final fileName = picture.path.split('/').last;
      final mimeType = lookupMimeType(picture.path) ?? 'image/png';

      // Step 1: Get presigned URL from your server using your configured _dioClient
      final response = await _dioClient.post(
        ApiEndpoints.uploadimage,
        data: {"fileName": fileName, "mimeType": mimeType, "folder": folder},
      );

      // Accessing data through dio's Response object layout (.data)
      final responseData = response.data['data'];
      final signedUrl = responseData['endpoint']; // Presigned S3 PUT URL
      final fileUrl = responseData['file']; // Public S3 file URL

      // Step 2: Upload file binary directly to AWS S3
      // NOTE: We use a clean, fresh Dio instance here because sending your backend's
      // interceptors or auth headers to Amazon S3 will cause a 403 Access Denied error.
      final uploadRes = await Dio().put(
        signedUrl,
        data: picture
            .openRead(), // Using a stream instead of readAsBytes is better for device memory
        options: Options(
          headers: {'Content-Type': mimeType, 'Content-Length': await picture.length()},
        ),
      );

      if (uploadRes.statusCode == 200) {
        print('Upload successful. File available at: $fileUrl');
        return fileUrl;
      } else {
        throw Exception('S3 upload failed');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> updateAccount({String? fullName, String? phone, String? picture}) async {
    Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (picture != null) data['profileImage'] = picture;
    final response = await _dioClient.patch(
      ApiEndpoints.accountupdate,
      data: {"fullName": fullName, "phone": phone, "profileImage": picture},
    );

    final res = response.data['data'];

    return UserModel.fromJson(res);
  }

  @override
  Future<void> deleteAccount() async {
    await _dioClient.delete(ApiEndpoints.accountupdate);
  }

  @override
  Future<AuthResponseModel> authenticateSso(
    String firebaseIdToken, {
    String? deviceId,
    String? fcmToken,
  }) async {
    final effectiveDeviceId = deviceId ?? await _localDataSource.getOrCreateDeviceId();
    final effectiveFcmToken = fcmToken ?? (await FirebaseMessaging.instance.getToken() ?? '');

    final response = await _dioClient.post(
      ApiEndpoints.authenticateSso,
      data: {
        "firebaseIdToken": firebaseIdToken,
        "deviceId": effectiveDeviceId,
        "fcmToken": effectiveFcmToken,
      },
    );
    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> changeAppPin(String oldPin, String newPin, String password) async {
    final response = await _dioClient.post(
      ApiEndpoints.changeAppPin,
      data: {"oldPin": oldPin, "newPin": int.tryParse(newPin) ?? 0, "password": password},
    );
    if (response.data == null || response.data['status'] != true) {
      final message = response.data?['message'] ?? 'Failed to change PIN';
      throw Exception(message);
    }
  }

  @override
  Future<String> getBiometricChallenge({required String email, required String deviceId}) async {
    final response = await _dioClient.post(
      ApiEndpoints.biometricChallenge,
      data: {"deviceId": deviceId, "userEmail": email},
    );
    final data = response.data['data'];
    if (data is Map) {
      return data['challenge'] as String;
    }
    return data as String;
  }

  @override
  Future<String> enrollBiometric({
    required String email,
    required String deviceId,
    required String publicKey,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.biometricEnroll,
      data: {"deviceId": deviceId, "userEmail": email, "publicKey": publicKey},
    );
    return response.data['data'] as String;
  }

  @override
  Future<AuthResponseModel> verifyBiometrics({
    required String email,
    required String deviceId,
    required String challenge,
    required String signatureBase64,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.biometricVerify,
      data: {
        "deviceId": deviceId,
        "userEmail": email,
        "signatureBase64": signatureBase64,
        "challenge": challenge,
      },
    );
    return AuthResponseModel.fromJson(response.data['data']);
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
