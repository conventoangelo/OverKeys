import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

/// Service for managing application startup behavior
class StartupService {
  /// Enables or disables the application from launching at system startup
  /// Returns true if successful, false if an error occurred
  Future<bool> handleStartupToggle(bool enable) async {
    try {
      if (enable) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(
            'Error ${enable ? 'enabling' : 'disabling'} launch at startup: $e');
        print('Stack trace: $stackTrace');
      }
      // Return false to indicate failure so the UI can revert the toggle
      return false;
    }
  }
}
