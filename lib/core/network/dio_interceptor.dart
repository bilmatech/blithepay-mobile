import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioInterceptor extends Interceptor {
  final Dio _dio;

  final AppLocalDataSource _localDataSource;
  final GlobalKey<NavigatorState> _navigatorKey;

  // Internal flags
  bool _isRefreshing = false;
  final List<void Function()> _retryQueue = [];
  final int _maxRetries = 3; // Max number of refresh attempts

  DioInterceptor({
    required Dio dio,

    required AppLocalDataSource localDataSource,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _dio = dio,
       _localDataSource = localDataSource,
       _navigatorKey = navigatorKey;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _localDataSource.getAccessToken();

    print('DioInterceptor - Adding Authorization header with token: $token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      return _handle401(err, handler);
    }

    String message;

    if (err.response == null) {
      // Network / timeout / socket
      message = 'No internet connection';
    } else {
      final data = err.response?.data;
      message = 'Something went wrong';

      if (data is Map<String, dynamic>) {
        message =
            data['message']?.toString() ?? data['error']?.toString() ?? message;
      } else if (data is String) {
        message = data;
      }
    }

    handler.reject(err.copyWith(error: message));
  }

  Future<void> _handle401(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshToken = await _localDataSource.getRefreshToken();

    if (refreshToken == null) {
      // No refresh token → force logout
      await _logoutUser();
      return handler.reject(err);
    }

    if (_isRefreshing) {
      _retryQueue.add(() async {
        final clonedResponse = await _retryRequest(err.requestOptions);
        handler.resolve(clonedResponse);
      });
      return;
    }

    _isRefreshing = true;
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        final response = await AuthRepository(
          dioClient: DioClient(_localDataSource),
          localDataSource: _localDataSource,
        ).refresh(refreshToken);
        await _localDataSource.saveTokens(response);

        // Retry queued requests
        for (final retry in _retryQueue) {
          retry();
        }
        _retryQueue.clear();

        final newResponse = await _retryRequest(err.requestOptions);
        handler.resolve(newResponse);

        _isRefreshing = false;
        return;
      } catch (_) {
        retryCount++;
        if (retryCount >= _maxRetries) {
          // Max retries reached → logout
          await _logoutUser();
          _retryQueue.clear();
          handler.reject(err);
          _isRefreshing = false;
          return;
        }
        // Optional: small delay before retrying
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await _localDataSource.getAccessToken();

    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        validateStatus: (_) => true, // accept all responses
      ),
    );
  }

  Future<void> _logoutUser() async {
    await _localDataSource.clearSession();

    // Navigate to login safely
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}
