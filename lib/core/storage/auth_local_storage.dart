import 'dart:convert';

import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AppLocalDataSource {
  Future<void> setOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
  Future<void> saveTokens(AuthTokensModel token);
  Future<void> saveSession(AuthResponseModel session);
  Future<AuthResponseModel?> getSession();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> clearSession();
}

class AppLocalDataSourceImpl implements AppLocalDataSource {
  final FlutterSecureStorage _storage;

  AppLocalDataSourceImpl(this._storage);

  static const _onboardingKey = 'onboarding_completed';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';
  static const _userKey = 'user';

  @override
  Future<void> setOnboardingCompleted() async {
    await _storage.write(key: _onboardingKey, value: 'true');
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  @override
  Future<void> saveTokens(AuthTokensModel token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
    await _storage.write(
      key: _expiresAtKey,
      value: token.expiresAt?.toIso8601String(),
    );
  }

  @override
  Future<void> saveSession(AuthResponseModel session) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(session.user?.toJson()),
    );
  }

  @override
  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<AuthResponseModel?> getSession() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null) return null;

    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);
    final userRaw = await _storage.read(key: _userKey);

    return AuthResponseModel(
      tokens: AuthTokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAtRaw != null ? DateTime.parse(expiresAtRaw) : null,
      ),
      user: userRaw != null ? UserModel.fromJson(jsonDecode(userRaw)) : null,
    );
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _userKey);
  }
}
