import 'package:dio/dio.dart';
import 'dio_client.dart';

String extractError(Object e, [String fallback = 'Something went wrong']) {
  if (e is NetworkException) {
    return e.message;
  }
  if (e is DioException && e.error is String) {
    return e.error as String;
  }
  final str = e.toString().replaceAll('Exception: ', '').trim();
  if (str.isNotEmpty && str != 'null' && !str.contains('DioException')) {
    return str;
  }
  return fallback;
}
