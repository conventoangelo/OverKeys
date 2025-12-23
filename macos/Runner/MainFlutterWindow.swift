import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  /// Configures the window to host a Flutter view controller and ensures Flutter plugins are registered for this and any subsequently created windows.
  /// 
  /// Sets the window's content view controller to a new `FlutterViewController`, preserves the current window frame, registers generated plugins for the initial Flutter controller, and installs a callback that registers generated plugins for any new window controllers created at runtime.
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      // Register all plugins for the new window
      RegisterGeneratedPlugins(registry: controller)
    }

    super.awakeFromNib()
  }
}