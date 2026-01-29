import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioInterceptor extends Interceptor {
  final AppLocalDataSource _localDataSource;
  final GlobalKey<NavigatorState> _navigatorKey;

  // Internal flags
  bool _isRefreshing = false;
  final List<void Function()> _retryQueue = [];
  final int _maxRetries = 3; // Max number of refresh attempts

  DioInterceptor({
    required AppLocalDataSource localDataSource,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _localDataSource = localDataSource,
       _navigatorKey = navigatorKey;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _localDataSource.getAccessToken();

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

    // Extract backend message
    String message = "Unknown error";
    try {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        // If backend sends multiple errors, combine them
        message =
            data['message']?.toString() ??
            data.values.map((e) => e.toString()).join(", ");
      } else if (data is List) {
        message = data.join(", ");
      } else if (data is String) {
        message = data;
      }
    } catch (_) {
      message = err.message ?? "Unknown error";
    }

   // print("Backend Error: $message"); // Log in terminal

    final newErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      error: message, 
      type: err.type,
    );

    handler.reject(newErr);
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
    final dio = Dio(); // or reuse base Dio instance safely

    final accessToken = await _localDataSource.getAccessToken();

    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    return dio.request(
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
