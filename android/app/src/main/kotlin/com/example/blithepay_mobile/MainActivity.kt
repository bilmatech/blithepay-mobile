package com.bilmatech.blithepayapp

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricManager
import androidx.core.content.ContextCompat
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.util.Base64

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.bilmatech.blithepayapp/biometrics"
    private val KEY_ALIAS = "blithepay_biometric_key"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "generateKeyPair" -> {
                    generateAndroidKeyPair(result)
                }
                "signPayload" -> {
                    val payload = call.argument<String>("payload")
                    if (payload != null) {
                        signPayload(payload, result)
                    } else {
                        result.error("INVALID_ARGS", "Missing payload string", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Generates a P-256 EC key pair in the Android KeyStore.
     * The private key is bound to the hardware and requires biometrics to be unlocked.
     * The public key is exported in standard X.509 PEM format.
     */
    private fun generateAndroidKeyPair(result: MethodChannel.Result) {
        try {
            // Check biometric enrollment status first to prevent IllegalStateException
            val biometricManager = BiometricManager.from(this)
            val canAuthenticate = biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            if (canAuthenticate == BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED) {
                result.error("BIOMETRICS_NOT_ENROLLED", "Please enroll at least one fingerprint or face in your device settings.", null)
                return
            } else if (canAuthenticate != BiometricManager.BIOMETRIC_SUCCESS) {
                result.error("BIOMETRICS_UNAVAILABLE", "Biometric authentication is not supported or active on this device.", null)
                return
            }

            val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            keyStore.deleteEntry(KEY_ALIAS)

            val keyPairGenerator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
            val spec = KeyGenParameterSpec.Builder(KEY_ALIAS, KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY)
                .setAlgorithmParameterSpec(java.security.spec.ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(true)
                .setInvalidatedByBiometricEnrollment(true) // Destroys key if new fingerprints/faces are registered
                .build()

            keyPairGenerator.initialize(spec)
            val keyPair = keyPairGenerator.generateKeyPair()
            
            val pubKeyBytes = keyPair.public.encoded
            val base64PubKey = Base64.getEncoder().encodeToString(pubKeyBytes)
            val pemKey = "-----BEGIN PUBLIC KEY-----\n$base64PubKey\n-----END PUBLIC KEY-----"
            result.success(pemKey)
        } catch (e: IllegalStateException) {
            result.error("BIOMETRICS_NOT_ENROLLED", "Please enroll at least one fingerprint or face in your device settings.", e.message)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("KEYGEN_FAIL", "Failed to generate KeyStore keys: ${e.message}", null)
        }
    }

    /**
     * Triggers the biometric prompt, unlocks the hardware private key,
     * and signs the provided payload (challenge) string.
     */
    private fun signPayload(payload: String, result: MethodChannel.Result) {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val entry = keyStore.getEntry(KEY_ALIAS, null) as? KeyStore.PrivateKeyEntry
        if (entry == null) {
            result.error("KEY_NOT_FOUND", "Enroll biometrics first", null)
            return
        }

        val signature = Signature.getInstance("SHA256withECDSA")
        signature.initSign(entry.privateKey)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric Login")
            .setSubtitle("Authenticate to securely login to your account")
            .setNegativeButtonText("Cancel")
            .build()

        val mainExecutor = ContextCompat.getMainExecutor(this)
        val biometricPrompt = BiometricPrompt(this, mainExecutor, object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(authResult)
                val unlockedSignature = authResult.cryptoObject?.signature
                unlockedSignature?.let {
                    it.update(payload.toByteArray(Charsets.UTF_8))
                    val signatureBytes = it.sign()
                    val signatureBase64 = Base64.getEncoder().encodeToString(signatureBytes)
                    result.success(signatureBase64)
                } ?: result.error("SIGN_FAIL", "CryptoObject null", null)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                result.error("AUTH_ERROR", errString.toString(), null)
            }
        })

        // Passing the signature wrapped in CryptoObject makes it a hardware-backed check
        biometricPrompt.authenticate(promptInfo, BiometricPrompt.CryptoObject(signature))
    }
}
