class Env {
  static const String baseUrl = 'https://apis.blithepay.com/api/';
  static const String apiVersion = 'v1';

  static String get fullBaseUrl => '$baseUrl/$apiVersion';

  /// Apple App Store ID for BlithePay (replace with your numerical ID from App Store Connect)
  static const String appStoreId = '6758208368';
}

// static const String baseUrl = 'https://blithepay-staging.bilma.me/api/';
// static const String baseUrl = 'https://apis.blithepay.com/api/';
