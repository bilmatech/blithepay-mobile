import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();

  late final FlutterSecureStorage _storage;

  SecureStorageService._internal() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        resetOnError: true,
      ),
    );
  }

  factory SecureStorageService() {
    return _instance;
  }

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  
  Future<String?> read(String key) => _storage.read(key: key);
  
  Future<void> delete(String key) => _storage.delete(key: key);
  
  Future<void> deleteAll() => _storage.deleteAll();
}
