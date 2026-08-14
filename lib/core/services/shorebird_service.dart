import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';

class ShorebirdService {
  ShorebirdService._privateConstructor();

  static final ShorebirdService instance = ShorebirdService._privateConstructor();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

  /// Checks if Shorebird is active and available on this build.
  bool get isShorebirdAvailable => _updater.isAvailable;

  /// Reads the currently running patch, if any.
  Future<Patch?> getCurrentPatch() async {
    if (!isShorebirdAvailable) return null;
    try {
      return await _updater.readCurrentPatch();
    } catch (e) {
      debugPrint('Error reading current Shorebird patch: $e');
      return null;
    }
  }

  /// Manually checks for updates and handles the user prompt flow.
  Future<void> checkAndPromptUpdate(BuildContext context, {bool showNoUpdateMessage = false}) async {
    if (!isShorebirdAvailable) {
      if (showNoUpdateMessage) {
        _showSnackBar(context, 'Shorebird is not available in this build (e.g. Debug/Emulator).');
      }
      return;
    }

    try {
      _showLoadingDialog(context, 'Checking for updates...');
      final status = await _updater.checkForUpdate();
      
      // Close the loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (status == UpdateStatus.outdated) {
        if (context.mounted) {
          _showUpdatePrompt(context);
        }
      } else if (status == UpdateStatus.restartRequired) {
        if (context.mounted) {
          _showRestartPrompt(context);
        }
      } else {
        if (showNoUpdateMessage && context.mounted) {
          _showSnackBar(context, 'App is up to date.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        _showSnackBar(context, 'Failed to check for updates: $e');
      }
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.system_update_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Update Available',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A new patch update is available. Download now to keep your app running smoothly.',
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _downloadUpdate(context);
                    },
                    child: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadUpdate(BuildContext context) async {
    _showLoadingDialog(context, 'Downloading update...');
    try {
      await _updater.update();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showRestartPrompt(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showSnackBar(context, 'Update failed: $e');
      }
    }
  }

  void _showRestartPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.offline_pin_rounded, size: 48, color: AppColors.success),
            const SizedBox(height: 16),
            const Text(
              'Restart Required',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The update has been downloaded successfully. Please restart the app to apply the changes.',
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
