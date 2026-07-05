import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../config/env.dart';
import 'package:blithepay/core/navigation/routes.dart';
import 'dio_interceptor.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  DioClient._internal(AppLocalDataSource localDataSource) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.fullBaseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConfig.connectionTimeout,
        ),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        contentType: 'application/json',
      ),
    );

    if (AppConfig.enableDebugLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    _dio.interceptors.add(
      DioInterceptor(
        dio: _dio,
        localDataSource: localDataSource,
        navigatorKey: rootNavigatorKey,
      ),
    );
  }

  factory DioClient(AppLocalDataSource localDataSource) {
    _instance ??= DioClient._internal(localDataSource);
    return _instance!;
  }

  Dio get instance => _dio;

  Future<Response<T>> _wrapRequest<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw NetworkException(_mapDioError(e));
    }
  }

  String _mapDioError(DioException err) {
    final error = err.error;
    if (error is String && error.isNotEmpty) {
      return error;
    }
    if (err.response == null) {
      return 'No internet connection';
    }
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['error']?.toString() ?? 'Something went wrong, please try again';
    }
    return 'Something went wrong, please try again';
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _wrapRequest(() => _dio.get<T>(path, queryParameters: queryParameters, options: options));

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _wrapRequest(() => _dio.post<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _wrapRequest(() => _dio.put<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _wrapRequest(() => _dio.delete<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _wrapRequest(() => _dio.patch<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  ));
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
