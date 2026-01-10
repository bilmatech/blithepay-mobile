import 'package:dio/dio.dart';
import 'network_exceptions.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    // options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.reject(err);
  }

  NetworkException _mapException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException(message: 'Connection timeout');
      case DioExceptionType.badResponse:
        return _mapStatusCodeException(error.response?.statusCode ?? 0);
      case DioExceptionType.connectionError:
        return const NetworkError(message: 'Network error');
      default:
        return ServerException(message: error.message ?? 'Unknown error');
    }
  }

  NetworkException _mapStatusCodeException(int statusCode) {
    switch (statusCode) {
      case 400:
        return const BadRequestException(message: 'Bad request');
      case 401:
        return const UnauthorizedException(message: 'Unauthorized');
      case 404:
        return const NotFoundException(message: 'Not found');
      default:
        return const ServerException(message: 'Server error');
    }
  }
}
