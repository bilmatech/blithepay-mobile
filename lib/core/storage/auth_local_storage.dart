import 'dart:convert';

import 'package:blithepay/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

abstract class AppLocalDataSource {
  Future<void> setOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
  Future<void> saveTokens(AuthTokensModel token);
  Future<void> saveSession(AuthResponseModel session);
  Future<void> updateSessionUser(UserModel updatedUser);
  Future<AuthResponseModel?> getSession();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<DateTime?> getExpiresAt();

  Future<void> clearSession();
  Stream<UserModel?> get userStream;

  Future<void> saveLastActiveTime(DateTime time);
  Future<DateTime?> getLastActiveTime();
  Future<void> clearLastActiveTime();

  Future<void> setBalanceVisible(bool visible);
  Future<bool> isBalanceVisible();
  Future<void> setBiometricsEnabled(bool enabled);
  Future<bool> isBiometricsEnabled();
  Future<void> setBiometricEmail(String email);
  Future<String?> getBiometricEmail();
  Future<void> clearBiometricEmail();
  Future<String> getOrCreateDeviceId();
}

class AppLocalDataSourceImpl implements AppLocalDataSource {
  final FlutterSecureStorage _storage;
  final BehaviorSubject<AuthResponseModel?> _sessionController =
      BehaviorSubject<AuthResponseModel?>();

  AppLocalDataSourceImpl(this._storage) {
    // Emit initial session on startup
    getSession().then((session) => _sessionController.add(session));
  }

  @override
  Stream<UserModel?> get userStream =>
      _sessionController.stream.map((session) => session?.user);

  static const _onboardingKey = 'onboarding_completed';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';
  static const _userKey = 'user';
  static const _balanceVisibleKey = 'wallet_balance_visible';
  static const _biometricsEnabledKey = 'biometrics_enabled';
  static const _biometricEmailKey = 'biometric_email';
  static const _deviceIdKey = 'device_id';

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
    _sessionController.add(session);
  }

  @override
  Future<void> updateSessionUser(UserModel updatedUser) async {
    final existing = await getSession();

    final newSession = AuthResponseModel(
      user: updatedUser,
      tokens: existing?.tokens,
      wallet: existing?.wallet,
    );

    await saveSession(newSession);
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
  Future<DateTime?> getExpiresAt() async {
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);
    return expiresAtRaw != null ? DateTime.parse(expiresAtRaw) : null;
  }

  @override
  Future<AuthResponseModel?> getSession() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null) return null;

    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);
    final userRaw = await _storage.read(key: _userKey);

    final session = AuthResponseModel(
      tokens: AuthTokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAtRaw != null ? DateTime.parse(expiresAtRaw) : null,
      ),
      user: userRaw != null ? UserModel.fromJson(jsonDecode(userRaw)) : null,
    );
    _sessionController.add(session);
    return session;
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
    await _storage.delete(key: _userKey);
    _sessionController.add(null);
  }

  @override
  Future<void> setBalanceVisible(bool visible) async {
    await _storage.write(key: _balanceVisibleKey, value: visible.toString());
  }

  @override
  Future<bool> isBalanceVisible() async {
    final value = await _storage.read(key: _balanceVisibleKey);
    return value == 'true';
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _biometricsEnabledKey, value: enabled.toString());
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    final value = await _storage.read(key: _biometricsEnabledKey);
    return value == 'true';
  }

  @override
  Future<void> setBiometricEmail(String email) async {
    await _storage.write(key: _biometricEmailKey, value: email);
  }

  @override
  Future<String?> getBiometricEmail() {
    return _storage.read(key: _biometricEmailKey);
  }

  @override
  Future<void> clearBiometricEmail() async {
    await _storage.delete(key: _biometricEmailKey);
  }

  @override
  Future<String> getOrCreateDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null) {
      final randomUuid = const Uuid().v4();
      final bytes = utf8.encode(randomUuid);
      deviceId = sha256.convert(bytes).toString();
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  @override
  Future<void> saveLastActiveTime(DateTime time) async {
    await _storage.write(key: 'session_last_active_time', value: time.toIso8601String());
  }

  @override
  Future<DateTime?> getLastActiveTime() async {
    final raw = await _storage.read(key: 'session_last_active_time');
    return raw != null ? DateTime.parse(raw) : null;
  }

  @override
  Future<void> clearLastActiveTime() async {
    await _storage.delete(key: 'session_last_active_time');
  }
}
