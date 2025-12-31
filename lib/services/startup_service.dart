import 'package:launch_at_startup/launch_at_startup.dart';

/// Service for managing application startup behavior
class StartupService {
  /// Enables or disables the application from launching at system startup
  Future<void> handleStartupToggle(bool enable) async {
    if (enable) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }
}
