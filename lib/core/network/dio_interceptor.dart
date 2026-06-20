import 'package:blithepay/core/network/api_endpoints.dart';
import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class QueuedRequest {
  final RequestOptions options;
  final dynamic handler; // Either RequestInterceptorHandler or ErrorInterceptorHandler

  QueuedRequest({required this.options, required this.handler});
}

class DioInterceptor extends Interceptor {
  final Dio _dio;
  final AppLocalDataSource _localDataSource;
  final GlobalKey<NavigatorState> _navigatorKey;

  // Internal flags and queue
  bool _isRefreshing = false;
  final List<QueuedRequest> _retryQueue = [];

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
    final path = options.path;
    // Skip refresh token logic on the refresh endpoint itself to prevent infinite loops
    if (path == ApiEndpoints.refreshToken) {
      handler.next(options);
      return;
    }

    final token = await _localDataSource.getAccessToken();
    final refreshToken = await _localDataSource.getRefreshToken();
    final expiresAt = await _localDataSource.getExpiresAt();

    if (token != null && token.isNotEmpty && refreshToken != null && expiresAt != null) {
      final now = DateTime.now();
      // Check if token is expired or expires in under 10 seconds
      if (now.isAfter(expiresAt) || expiresAt.difference(now).inSeconds <= 10) {
        if (_isRefreshing) {
          print('DioInterceptor [onRequest] - Refresh already in progress. Enqueueing request: ${options.path}');
          _retryQueue.add(QueuedRequest(options: options, handler: handler));
          return;
        }

        _isRefreshing = true;

        try {
          print('DioInterceptor [onRequest] - Token expired/expiring soon. Refreshing token pre-emptively...');
          final response = await AuthRepository(
            dioClient: DioClient(_localDataSource),
            localDataSource: _localDataSource,
          ).refresh(refreshToken);

          await _localDataSource.saveTokens(response);
          final newAccessToken = response.accessToken;
          print('DioInterceptor [onRequest] - Refresh succeeded. Dispatching queued requests...');

          // Proceed with current request
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          handler.next(options);

          // Proceed with queued requests
          for (final queued in _retryQueue) {
            final h = queued.handler;
            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              queued.options.headers['Authorization'] = 'Bearer $newAccessToken';
            }
            if (h is RequestInterceptorHandler) {
              h.next(queued.options);
            } else if (h is ErrorInterceptorHandler) {
              try {
                final clonedResponse = await _retryRequest(queued.options, newAccessToken);
                h.resolve(clonedResponse);
              } catch (e) {
                h.reject(DioException(requestOptions: queued.options, error: e));
              }
            }
          }
          _retryQueue.clear();
        } catch (e) {
          print('DioInterceptor [onRequest] - Refresh failed: $e. Forcing logout...');
          // Reject all queued requests
          for (final queued in _retryQueue) {
            final h = queued.handler;
            final exception = DioException(
              requestOptions: queued.options,
              error: 'Session expired. Please log in again.',
              type: DioExceptionType.cancel,
            );
            if (h is RequestInterceptorHandler) {
              h.reject(exception);
            } else if (h is ErrorInterceptorHandler) {
              h.reject(exception);
            }
          }
          _retryQueue.clear();

          // Reject current request
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Session expired. Please log in again.',
              type: DioExceptionType.cancel,
            ),
          );

          await _logoutUser();
        } finally {
          _isRefreshing = false;
        }
        return;
      }
    }

    // Token is valid or not available, append and proceed with original request
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
      await _logoutUser();
      return handler.reject(err);
    }

    if (_isRefreshing) {
      print('DioInterceptor [onError] - Refresh already in progress. Enqueueing request: ${err.requestOptions.path}');
      _retryQueue.add(QueuedRequest(options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      print('DioInterceptor [onError] - 401 Unauthorized. Refreshing token...');
      final response = await AuthRepository(
        dioClient: DioClient(_localDataSource),
        localDataSource: _localDataSource,
      ).refresh(refreshToken);

      await _localDataSource.saveTokens(response);
      final newAccessToken = response.accessToken;
      print('DioInterceptor [onError] - Refresh succeeded. Retrying failed request...');

      // Retry current failed request
      final clonedResponse = await _retryRequest(err.requestOptions, newAccessToken);
      handler.resolve(clonedResponse);

      // Process queued requests
      for (final queued in _retryQueue) {
        final h = queued.handler;
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          queued.options.headers['Authorization'] = 'Bearer $newAccessToken';
        }
        if (h is RequestInterceptorHandler) {
          h.next(queued.options);
        } else if (h is ErrorInterceptorHandler) {
          try {
            final clonedResponse = await _retryRequest(queued.options, newAccessToken);
            h.resolve(clonedResponse);
          } catch (e) {
            h.reject(DioException(requestOptions: queued.options, error: e));
          }
        }
      }
      _retryQueue.clear();
    } catch (e) {
      print('DioInterceptor [onError] - Refresh failed: $e. Forcing logout...');
      for (final queued in _retryQueue) {
        final h = queued.handler;
        final exception = DioException(
          requestOptions: queued.options,
          error: 'Session expired. Please log in again.',
          type: DioExceptionType.cancel,
        );
        if (h is RequestInterceptorHandler) {
          h.reject(exception);
        } else if (h is ErrorInterceptorHandler) {
          h.reject(exception);
        }
      }
      _retryQueue.clear();
      handler.reject(err);
      await _logoutUser();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions, String? newAccessToken) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $newAccessToken';
    }

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        validateStatus: (_) => true, // Accept all responses
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
