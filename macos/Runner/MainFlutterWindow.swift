import Cocoa
import FlutterMacOS
import LaunchAtLogin
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  private let keyboardMonitor = KeyboardMonitor()

  override var canBecomeKey: Bool {
    return false
  }

  override var canBecomeMain: Bool {
    return false
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    flutterViewController.backgroundColor = NSColor.clear

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.backgroundColor = NSColor.clear
    self.isOpaque = false
    self.hasShadow = false
    self.collectionBehavior.insert(.canJoinAllSpaces)
    self.collectionBehavior.insert(.fullScreenAuxiliary)

    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor
    flutterViewController.view.layer?.isOpaque = false

    RegisterGeneratedPlugins(registry: flutterViewController)

    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
    }

    let keyboardEventChannel = FlutterEventChannel(
      name: "overkeys/keyboard_events",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    keyboardEventChannel.setStreamHandler(keyboardMonitor)

    let keyboardMethodChannel = FlutterMethodChannel(
      name: "overkeys/keyboard_monitor",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    keyboardMethodChannel.setMethodCallHandler(keyboardMonitor.handleMethodCall)

    let launchAtStartupChannel = FlutterMethodChannel(
      name: "launch_at_startup",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    launchAtStartupChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "launchAtStartupIsEnabled":
        result(LaunchAtLogin.isEnabled)
      case "launchAtStartupSetEnabled":
        if let arguments = call.arguments as? [String: Any],
           let isEnabled = arguments["setEnabledValue"] as? Bool {
          LaunchAtLogin.isEnabled = isEnabled
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
