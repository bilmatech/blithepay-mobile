import 'package:flutter/services.dart';

/// Service interfacing with native iOS (Secure Enclave) and Android (KeyStore)
/// biometric cryptographic capabilities over standard Platform Channels.
class BiometricCryptoService {
  // Method Channel identifier matching AppDelegate.swift & MainActivity.kt
  static const MethodChannel _channel = MethodChannel('com.bilmatech.blithepayapp/biometrics');

  /// Calls native code to generate an ECDSA P-256 key pair inside hardware security module.
  /// Returns the generated Public Key in standard PEM format.
  static Future<String?> generateKeyPair() async {
    return await _channel.invokeMethod<String>('generateKeyPair');
  }

  /// Calls native code to prompt user for biometrics and sign the provided [payload] challenge.
  /// Returns the ECDSA SHA-256 signature in Base64 string format.
  static Future<String?> signChallenge(String payload) async {
    try {
      final String? signature = await _channel.invokeMethod<String>('signPayload', {
        'payload': payload,
      });
      return signature;
    } on PlatformException catch (e) {
      print("Error signing biometric challenge: ${e.message}");
      return null;
    }
  }
}
