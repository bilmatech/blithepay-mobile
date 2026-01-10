class Env {
  static const String baseUrl = 'https://api.buthe.app';
  static const String apiVersion = 'v1';
  
  static String get fullBaseUrl => '$baseUrl/$apiVersion';
}
