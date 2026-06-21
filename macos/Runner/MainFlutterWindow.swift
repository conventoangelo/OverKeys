import Cocoa
import FlutterMacOS
import LaunchAtLogin
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  private let keyboardMonitor = KeyboardMonitor()
  private weak var flutterViewController: FlutterViewController?
  private var windowMethodChannel: FlutterMethodChannel?
  private var isKeyboardOverlayWindow = false

  override var canBecomeKey: Bool {
    return !isKeyboardOverlayWindow
  }

  override var canBecomeMain: Bool {
    return !isKeyboardOverlayWindow
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.flutterViewController = flutterViewController

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

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

    let windowMethodChannel = FlutterMethodChannel(
      name: "overkeys/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    self.windowMethodChannel = windowMethodChannel
    windowMethodChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "configureKeyboardOverlay":
        self?.configureKeyboardOverlay()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    configurePreferencesMenu()

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

  private func configureKeyboardOverlay() {
    isKeyboardOverlayWindow = true
    backgroundColor = NSColor.clear
    isOpaque = false
    hasShadow = false
    collectionBehavior.insert(.canJoinAllSpaces)
    collectionBehavior.insert(.fullScreenAuxiliary)

    flutterViewController?.backgroundColor = NSColor.clear
    flutterViewController?.view.wantsLayer = true
    flutterViewController?.view.layer?.backgroundColor = NSColor.clear.cgColor
    flutterViewController?.view.layer?.isOpaque = false
  }

  private func configurePreferencesMenu() {
    guard let appMenu = NSApp.mainMenu?.items.first?.submenu else {
      return
    }

    if let preferencesItem = appMenu.items.first(where: { $0.keyEquivalent == "," }) {
      preferencesItem.target = self
      preferencesItem.action = #selector(openPreferencesFromMenu(_:))
      preferencesItem.isEnabled = true
    }
  }

  @objc private func openPreferencesFromMenu(_ sender: Any?) {
    windowMethodChannel?.invokeMethod("openPreferences", arguments: nil)
  }
}
