import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../config/env.dart';
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

    final navigatorKey = GlobalKey<NavigatorState>();

    _dio.interceptors.add(
      DioInterceptor(
        localDataSource: localDataSource,
        navigatorKey: navigatorKey,
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
  }

  factory DioClient(AppLocalDataSource localDataSource) {
    _instance ??= DioClient._internal(localDataSource);
    return _instance!;
  }

  Dio get instance => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.post<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.put<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.delete<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );
}
