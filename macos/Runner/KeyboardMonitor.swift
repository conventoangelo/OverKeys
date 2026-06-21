import Cocoa
import Carbon.HIToolbox
import FlutterMacOS
import IOKit.hid

final class KeyboardMonitor: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var eventTap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?
  private var lockObserver: NSObjectProtocol?
  private var unlockObserver: NSObjectProtocol?
  private var isMonitoring = false

  func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkPermissions":
      result(Self.permissionStatus())
    case "requestPermissions":
      Self.requestPermissions()
      Self.presentPermissionHelpIfNeeded()
      result(nil)
    case "openAccessibilitySettings":
      Self.openAccessibilitySettings()
      result(nil)
    case "openInputMonitoringSettings":
      Self.openInputMonitoringSettings()
      result(nil)
    case "stopMonitoring":
      stopMonitoring()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events

    do {
      try startMonitoring()
      return nil
    } catch {
      Self.presentPermissionHelpIfNeeded()
      return FlutterError(
        code: "KEYBOARD_MONITOR_UNAVAILABLE",
        message: error.localizedDescription,
        details: Self.permissionStatus()
      )
    }
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopMonitoring()
    eventSink = nil
    return nil
  }

  private func startMonitoring() throws {
    guard !isMonitoring else { return }

    guard Self.hasAllPermissions() else {
      throw KeyboardMonitorError.missingPermissions(Self.permissionStatus())
    }

    let eventMask =
      (1 << CGEventType.keyDown.rawValue) |
      (1 << CGEventType.keyUp.rawValue) |
      (1 << CGEventType.flagsChanged.rawValue)

    guard let tap = CGEvent.tapCreate(
      tap: .cgSessionEventTap,
      place: .headInsertEventTap,
      options: .listenOnly,
      eventsOfInterest: CGEventMask(eventMask),
      callback: { _, type, event, refcon in
        guard let refcon = refcon else {
          return Unmanaged.passUnretained(event)
        }

        let monitor = Unmanaged<KeyboardMonitor>
          .fromOpaque(refcon)
          .takeUnretainedValue()
        monitor.handleEvent(type: type, event: event)

        return Unmanaged.passUnretained(event)
      },
      userInfo: Unmanaged.passUnretained(self).toOpaque()
    ) else {
      throw KeyboardMonitorError.eventTapUnavailable(Self.permissionStatus())
    }

    eventTap = tap
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

    if let source = runLoopSource {
      CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
    }

    CGEvent.tapEnable(tap: tap, enable: true)
    startSessionNotifications()
    isMonitoring = true
  }

  private func stopMonitoring() {
    guard isMonitoring else { return }

    if let tap = eventTap {
      CGEvent.tapEnable(tap: tap, enable: false)
      CFMachPortInvalidate(tap)
    }

    if let source = runLoopSource {
      CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
    }

    stopSessionNotifications()
    eventTap = nil
    runLoopSource = nil
    isMonitoring = false
  }

  private func handleEvent(type: CGEventType, event: CGEvent) {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
      if let tap = eventTap {
        CGEvent.tapEnable(tap: tap, enable: true)
      }
      return
    case .keyDown, .keyUp, .flagsChanged:
      break
    default:
      return
    }

    let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
    let isPressed: Bool

    if type == .flagsChanged {
      isPressed = Self.isModifierPressed(keyCode: keyCode, flags: event.flags)
    } else {
      isPressed = type == .keyDown
    }

    let isShiftDown = event.flags.contains(.maskShift)
    send([keyCode, isPressed, isShiftDown])
  }

  private func send(_ event: [Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }

  private func startSessionNotifications() {
    let center = DistributedNotificationCenter.default()
    lockObserver = center.addObserver(
      forName: Notification.Name("com.apple.screenIsLocked"),
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.send(["session_lock", true])
    }

    unlockObserver = center.addObserver(
      forName: Notification.Name("com.apple.screenIsUnlocked"),
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.send(["session_unlock", true])
    }
  }

  private func stopSessionNotifications() {
    let center = DistributedNotificationCenter.default()
    if let observer = lockObserver {
      center.removeObserver(observer)
    }
    if let observer = unlockObserver {
      center.removeObserver(observer)
    }
    lockObserver = nil
    unlockObserver = nil
  }

  private static func isModifierPressed(keyCode: Int, flags: CGEventFlags) -> Bool {
    switch keyCode {
    case kVK_Shift, kVK_RightShift:
      return flags.contains(.maskShift)
    case kVK_Control, kVK_RightControl:
      return flags.contains(.maskControl)
    case kVK_Option, kVK_RightOption:
      return flags.contains(.maskAlternate)
    case kVK_Command, kVK_RightCommand:
      return flags.contains(.maskCommand)
    case kVK_CapsLock:
      return flags.contains(.maskAlphaShift)
    default:
      return false
    }
  }

  static func permissionStatus() -> [String: Bool] {
    [
      "accessibility": hasAccessibilityPermission(prompt: false),
      "inputMonitoring": hasInputMonitoringPermission(),
    ]
  }

  private static func hasAllPermissions() -> Bool {
    hasAccessibilityPermission(prompt: false) && hasInputMonitoringPermission()
  }

  private static func hasAccessibilityPermission(prompt: Bool) -> Bool {
    if prompt {
      let options = [
        kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
      ] as CFDictionary
      return AXIsProcessTrustedWithOptions(options)
    }

    return AXIsProcessTrusted()
  }

  private static func hasInputMonitoringPermission() -> Bool {
    if #available(macOS 10.15, *) {
      return IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
    }
    return true
  }

  private static func requestPermissions() {
    _ = hasAccessibilityPermission(prompt: true)

    if #available(macOS 10.15, *) {
      if !hasInputMonitoringPermission() {
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
      }
    }
  }

  private static func presentPermissionHelpIfNeeded() {
    let status = permissionStatus()
    guard status["accessibility"] != true || status["inputMonitoring"] != true else {
      return
    }

    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = "Keyboard Monitoring Permission Required"
      alert.informativeText =
        "OverKeys needs Accessibility and Input Monitoring permission to highlight global keystrokes. Grant access in System Settings > Privacy & Security, then restart OverKeys."
      alert.addButton(withTitle: "Open Accessibility")
      alert.addButton(withTitle: "Open Input Monitoring")
      alert.addButton(withTitle: "Not Now")

      let response = alert.runModal()
      if response == .alertFirstButtonReturn {
        Self.openAccessibilitySettings()
      } else if response == .alertSecondButtonReturn {
        Self.openInputMonitoringSettings()
      }
    }
  }

  private static func openAccessibilitySettings() {
    openSettings("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
  }

  private static func openInputMonitoringSettings() {
    openSettings("x-apple.systempreferences:com.apple.preference.security?Privacy_InputMonitoring")
  }

  private static func openSettings(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    NSWorkspace.shared.open(url)
  }
}

private enum KeyboardMonitorError: LocalizedError {
  case missingPermissions([String: Bool])
  case eventTapUnavailable([String: Bool])

  var errorDescription: String? {
    switch self {
    case .missingPermissions:
      return "OverKeys does not have the macOS permissions required to monitor keyboard events."
    case .eventTapUnavailable:
      return "OverKeys could not create the macOS keyboard event tap."
    }
  }
}
