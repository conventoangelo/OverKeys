import 'package:launch_at_startup/launch_at_startup.dart';
import '../utils/logger.dart';

/// Service for managing application startup behavior
class StartupService {
  /// Logger instance for this service
  final _log = SimplePrintLogger('StartupService');

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
      _log.error('Error ${enable ? 'enabling' : 'disabling'} launch at startup',
          error: e, stackTrace: stackTrace);
      // Return false to indicate failure so the UI can revert the toggle
      return false;
    }
  }
}
