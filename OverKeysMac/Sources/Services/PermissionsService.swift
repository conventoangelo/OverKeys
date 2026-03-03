// PermissionsService.swift
// Checks and requests Accessibility + Input Monitoring permissions.

import AppKit
import ApplicationServices

// MARK: - Permission status

enum PermissionStatus: Equatable {
    case granted
    case denied
    case unknown
}

// MARK: - PermissionsService

final class PermissionsService {

    // MARK: Accessibility

    /// Returns true if the app is trusted for Accessibility access.
    static func accessibilityStatus() -> PermissionStatus {
        let trusted = AXIsProcessTrustedWithOptions(
            ["AXTrustedCheckOptionPrompt": false] as CFDictionary
        )
        return trusted ? .granted : .denied
    }

    /// Prompts the user to grant Accessibility permission via system dialog.
    static func requestAccessibility() {
        AXIsProcessTrustedWithOptions(
            ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        )
    }

    // MARK: Input Monitoring
    // OverKeysMac uses CGEventTap, not IOHIDManager, so Input Monitoring
    // (kIOHIDRequestTypeListenEvent) is not required. Accessibility alone gates the tap.

    static func inputMonitoringStatus() -> PermissionStatus { .granted }

    static func requestInputMonitoring() {}

    // MARK: Aggregate check

    /// Returns true if the app has all permissions needed to run an event tap.
    static func hasRequiredPermissions() -> Bool {
        if accessibilityStatus() != .granted { return false }
        if inputMonitoringStatus() == .denied { return false }
        return true
    }

    // MARK: Deep-link to System Settings

    static func openAccessibilitySettings() {
        let url: URL
        if #available(macOS 13, *) {
            url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility")!
        } else {
            url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        }
        NSWorkspace.shared.open(url)
    }

    static func openInputMonitoringSettings() {
        let url: URL
        if #available(macOS 13, *) {
            url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ListenEvent")!
        } else {
            url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        }
        NSWorkspace.shared.open(url)
    }
}
