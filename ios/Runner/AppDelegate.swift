import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

//  FIX: Safely guard against a nil window or root view controller
    guard let rootViewController = window?.rootViewController as? FlutterViewController else {
            // If the window isn't initialized yet, register plugins and let it load normally
            GeneratedPluginRegistrant.register(with: self)
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    let biometricChannel = FlutterMethodChannel(name: "com.bilmatech.blithepayapp/biometrics",
                                              binaryMessenger: rootViewController.binaryMessenger)
    
    biometricChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "generateKeyPair" {
          if let pubKey = self.generateSecureEnclaveKey() {
              result(pubKey)
          } else {
              result(FlutterError(code: "KEYGEN_FAIL", message: "Failed to generate EC key pair in Secure Enclave", details: nil))
          }
      } else if call.method == "signPayload" {
          guard let args = call.arguments as? [String: Any],
                let payload = args["payload"] as? String else {
              result(FlutterError(code: "INVALID_ARGS", message: "Missing payload to sign", details: nil))
              return
          }
          self.signData(payload: payload, result: result)
      } else {
          result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let biometricChannel = FlutterMethodChannel(name: "com.bilmatech.blithepayapp/biometrics",
                                                binaryMessenger: controller.binaryMessenger)
      
      biometricChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard let self = self else { return }
        if call.method == "generateKeyPair" {
            if let pubKey = self.generateSecureEnclaveKey() {
                result(pubKey)
            } else {
                result(FlutterError(code: "KEYGEN_FAIL", message: "Failed to generate EC key pair in Secure Enclave", details: nil))
            }
        } else if call.method == "signPayload" {
            guard let args = call.arguments as? [String: Any],
                  let payload = args["payload"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing payload to sign", details: nil))
                return
            }
            self.signData(payload: payload, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
      })
    }

    return result
  }

  private func generateSecureEnclaveKey() -> String? {
      let tag = "com.blithepay.biometricKey".data(using: .utf8)!
      
      let query: [String: Any] = [
          kSecClass as String: kSecClassKey,
          kSecAttrApplicationTag as String: tag
      ]
      SecItemDelete(query as CFDictionary)
      
      guard let accessControl = SecAccessControlCreateWithFlags(
          kCFAllocatorDefault,
          kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
          [.biometryCurrentSet, .privateKeyUsage], // Key invalidates if biometrics are updated/added
          nil
      ) else { return nil }

      let attributes: [String: Any] = [
          kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
          kSecAttrKeySizeInBits as String: 256,
          kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave, // Store private key in hardware
          kSecPrivateKeyAttrs as String: [
              kSecAttrIsPermanent as String: true,
              kSecAttrApplicationTag as String: tag,
              kSecAttrAccessControl as String: accessControl
          ]
      ]

      var error: Unmanaged<CFError>?
      guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else { return nil }
      guard let publicKey = SecKeyCopyPublicKey(privateKey) else { return nil }
      guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else { return nil }
      
      let base64Key = keyData.base64EncodedString(options: .lineLength64Characters)
      return "-----BEGIN PUBLIC KEY-----\n\(base64Key)\n-----END PUBLIC KEY-----"
  }

  private func signData(payload: String, result: @escaping FlutterResult) {
      let tag = "com.blithepay.biometricKey".data(using: .utf8)!
      let query: [String: Any] = [
          kSecClass as String: kSecClassKey,
          kSecAttrApplicationTag as String: tag,
          kSecReturnRef as String: true
      ]
      
      var item: CFTypeRef?
      let status = SecItemCopyMatching(query as CFDictionary, &item)
      guard status == errSecSuccess, let privateKey = (item as! SecKey?) else {
          result(FlutterError(code: "KEY_NOT_FOUND", message: "Private key not found. Please enroll biometrics again.", details: nil))
          return
      }
      
      let dataToSign = payload.data(using: .utf8)! as CFData
      var error: Unmanaged<CFError>?
      
      // Attempting to sign using the locked key triggers iOS system Face ID/Touch ID prompt
      guard let signature = SecKeyCreateSignature(privateKey, .ecdsaSignatureMessageX962SHA256, dataToSign, &error) else {
          result(FlutterError(code: "SIGN_FAIL", message: "Failed to sign: \(error!.takeRetainedValue().localizedDescription)", details: nil))
          return
      }
      
      result((signature as Data).base64EncodedString())
  }
}

