import 'package:launch_at_startup/launch_at_startup.dart';

/// Service for managing application startup behavior
class StartupService {
  /// Initializes startup settings
  Future<void> initStartup() async {
    // Startup initialization if needed
  }

  /// Handles enabling or disabling launch at startup
  Future<void> handleStartupToggle(bool enable) async {
    if (enable) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
    await initStartup();
  }
}
