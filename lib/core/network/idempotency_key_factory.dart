import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class IdempotencyKeyFactory {
  // Map to store keys. Key is a hash of the transaction conditions (invoiceId + sorted feeItemIds)
  static final Map<String, String> _cache = {};

  /// Generates a deterministic hash representing the transaction conditions
  static String _generateConditionHash(String invoiceId, List<String> feeItemIds) {
    // Sort feeItemIds to ensure order doesn't change the hash for the same set of items
    final sortedItemIds = List<String>.from(feeItemIds)..sort();
    final rawString = '$invoiceId:${sortedItemIds.join(',')}';
    final bytes = utf8.encode(rawString);
    return sha256.convert(bytes).toString();
  }

  /// Gets the existing idempotency key for the given transaction conditions,
  /// or generates a new one (a UUID v4) if it doesn't exist.
  static String getOrCreateKey(String invoiceId, List<String> feeItemIds) {
    final conditionHash = _generateConditionHash(invoiceId, feeItemIds);
    if (!_cache.containsKey(conditionHash)) {
      _cache[conditionHash] = const Uuid().v4();
    }
    return _cache[conditionHash]!;
  }

  /// Explicitly rotates (regenerates) the idempotency key for the given transaction conditions
  /// e.g. after a definitive failure or if a fresh attempt is requested by the UI.
  static String rotateKey(String invoiceId, List<String> feeItemIds) {
    final conditionHash = _generateConditionHash(invoiceId, feeItemIds);
    final newKey = const Uuid().v4();
    _cache[conditionHash] = newKey;
    return newKey;
  }

  /// Clears the cached key for the given transaction conditions (e.g., after success)
  static void clearKey(String invoiceId, List<String> feeItemIds) {
    final conditionHash = _generateConditionHash(invoiceId, feeItemIds);
    _cache.remove(conditionHash);
  }

  /// Clears all cached keys
  static void clearAll() {
    _cache.clear();
  }
}
