import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/features/auth/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class DioInterceptor extends Interceptor {
  final AppLocalDataSource _localDataSource;

  bool _isRefreshing = false;
  final List<void Function()> _retryQueue = [];

  DioInterceptor(this._localDataSource);

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
      await _localDataSource.clearSession();
      return handler.reject(err);
    }

    if (_isRefreshing) {
      _retryQueue.add(() async {
        final clonedRequest = await _retryRequest(err.requestOptions);
        handler.resolve(clonedRequest);
      });
      return;
    }

    _isRefreshing = true;

    try {
      final response = await AuthRepository(
        dioClient: DioClient(_localDataSource),
        localDataSource: _localDataSource,
      ).refresh(refreshToken);

      await _localDataSource.saveTokens(response);

      _isRefreshing = false;

      for (final retry in _retryQueue) {
        retry();
      }
      _retryQueue.clear();

      final newResponse = await _retryRequest(err.requestOptions);
      handler.resolve(newResponse);
    } catch (_) {
      _isRefreshing = false;
      _retryQueue.clear();
      await _localDataSource.clearSession();
      handler.reject(err);
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
}

