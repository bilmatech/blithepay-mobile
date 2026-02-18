import 'package:dio/dio.dart';

String extractError(Object e, [String fallback = 'Something went wrong']) {
  if (e is DioException && e.error is String) {
    return e.error as String;
  }
  return fallback;
}
