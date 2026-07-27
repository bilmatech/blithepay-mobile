import 'package:blithepay/core/config/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';

class RatingService {
  final InAppReview _inAppReview = InAppReview.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _lastPromptKey = 'last_rating_prompt_timestamp';
  static const int _minDaysBetweenPrompts = 30;

  /// Prompts for rating if eligible (e.g. at least 30 days since last prompt)
  /// or when [force] is true.
  Future<void> promptReviewIfEligible({
    bool force = false,
    String? appStoreId,
  }) async {
    final targetAppStoreId = appStoreId ?? (Env.appStoreId.isNotEmpty ? Env.appStoreId : null);
    try {
      if (!force) {
        final lastPromptStr = await _storage.read(key: _lastPromptKey);
        if (lastPromptStr != null) {
          final lastPrompt = DateTime.tryParse(lastPromptStr);
          if (lastPrompt != null) {
            final difference = DateTime.now().difference(lastPrompt).inDays;
            if (difference < _minDaysBetweenPrompts) {
              return; // Quota/Frequency control: skip prompt
            }
          }
        }
      }

      // Record current timestamp as last prompt attempt
      await _storage.write(
        key: _lastPromptKey,
        value: DateTime.now().toIso8601String(),
      );

      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        // Fallback to direct store listing if in-app dialog is unavailable
        await _inAppReview.openStoreListing(appStoreId: targetAppStoreId);
      }
    } catch (_) {
      // Ignore rating prompt failures gracefully
    }
  }

  /// Opens store listing page directly (e.g. from Settings/Help screen)
  Future<void> openStoreListing({String? appStoreId}) async {
    final targetAppStoreId = appStoreId ?? (Env.appStoreId.isNotEmpty ? Env.appStoreId : null);
    try {
      await _inAppReview.openStoreListing(appStoreId: targetAppStoreId);
    } catch (_) {}
  }
}
