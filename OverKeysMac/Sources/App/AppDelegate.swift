// AppDelegate.swift

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    let viewModel = KeyboardViewModel()
    var overlayWindowController: OverlayWindowController?

    private var statusItem: NSStatusItem?
    private var settingsWindowController: NSWindowController?

    // MARK: - applicationDidFinishLaunching

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as background agent — no Dock icon.
        NSApp.setActivationPolicy(.accessory)

        // Check permissions state (read-only, no prompt yet).
        viewModel.checkPermissions()

        // Build menu bar BEFORE the overlay window so it appears first.
        buildMenuBar()

        // Build the transparent overlay window.
        let wc = OverlayWindowController(viewModel: viewModel)
        overlayWindowController = wc
        wc.showWindow(nil)

        // Always attempt capture. EventTapService calls onPermissionDenied if
        // the tap cannot be created (i.e. Accessibility not granted), which
        // updates the view model so the overlay can show the permissions banner.
        viewModel.startCapture()

        // Poll for successful capture — handles the "grant while app is running" case.
        scheduleCapRetry()

        // If we know Accessibility is missing, prompt immediately.
        if viewModel.accessibilityStatus != .granted {
            promptForAccessibility()
        }
    }

    /// Poll every 3 s (max 10 attempts) until the EventTap is active.
    /// This lets the app recover automatically after the user grants Accessibility.
    @MainActor
    private func scheduleCapRetry(attempts: Int = 0) {
        guard attempts < 10 else { return }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard let self else { return }
            if !viewModel.isCaptureActive {
                viewModel.checkPermissions()
                viewModel.startCapture()
                scheduleCapRetry(attempts: attempts + 1)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        viewModel.stopCapture()
        overlayWindowController?.savePosition()
    }

    // MARK: - Accessibility prompt

    private func promptForAccessibility() {
        let alert = NSAlert()
        alert.messageText     = "Accessibility Permission Required"
        alert.informativeText = "OverKeys needs Accessibility access to capture global key events.\n\nClick \"Open Settings\", toggle OverKeysMac on, then use \"Restart Capture\" from the menu bar (or wait — it retries automatically)."
        alert.alertStyle      = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")

        // Bring the alert to front as a floating window.
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            PermissionsService.openAccessibilitySettings()
        }
        NSApp.setActivationPolicy(.accessory)
    }

    // MARK: - Menu bar

    private func buildMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.title   = "⌨ Keys"
            button.toolTip = "OverKeys"
        }

        let menu = NSMenu(title: "OverKeys")

        addItem(to: menu, title: "Show Overlay",     action: #selector(toggleOverlay))
        addItem(to: menu, title: "Click-through",    action: #selector(toggleClickThrough))
        menu.addItem(.separator())

        // Monitor submenu
        let monitorMenu = NSMenu(title: "Move to Monitor")
        for (i, screen) in NSScreen.screens.enumerated() {
            let item = NSMenuItem(title: screen.localizedName,
                                  action: #selector(moveToMonitor(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.tag    = i
            monitorMenu.addItem(item)
        }
        let monitorItem = NSMenuItem(title: "Move to Monitor", action: nil, keyEquivalent: "")
        monitorItem.submenu = monitorMenu
        menu.addItem(monitorItem)
        menu.addItem(.separator())

        addItem(to: menu, title: "Preferences…",    action: #selector(openPreferences),  key: ",")
        addItem(to: menu, title: "Open Config File",action: #selector(openConfig))
        addItem(to: menu, title: "Reload Config",   action: #selector(reloadConfig))
        menu.addItem(.separator())
        addItem(to: menu, title: "Restart Capture",           action: #selector(restartCapture))
        addItem(to: menu, title: "Grant Accessibility…",     action: #selector(grantAccessibility))
        addItem(to: menu, title: "Grant Input Monitoring…",  action: #selector(grantInputMonitoring))
        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit OverKeys",
                              action: #selector(NSApplication.terminate(_:)),
                              keyEquivalent: "q")
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    @discardableResult
    private func addItem(to menu: NSMenu,
                         title: String,
                         action: Selector,
                         key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
        return item
    }

    // MARK: - Menu actions

    @objc private func toggleOverlay() {
        viewModel.isOverlayVisible.toggle()
        if viewModel.isOverlayVisible {
            overlayWindowController?.showWindow(nil)
        } else {
            overlayWindowController?.window?.orderOut(nil)
        }
    }

    @objc private func toggleClickThrough() {
        viewModel.updatePreferences { $0.clickThrough.toggle() }
    }

    @objc private func moveToMonitor(_ sender: NSMenuItem) {
        overlayWindowController?.moveToScreen(at: sender.tag)
    }

    @objc private func openConfig()   { ConfigService.openInEditor() }
    @objc private func reloadConfig() { viewModel.reloadConfig() }

    @objc private func restartCapture() {
        viewModel.stopCapture()
        viewModel.checkPermissions()
        viewModel.startCapture()
    }

    @objc private func grantAccessibility() {
        PermissionsService.openAccessibilitySettings()
    }

    @objc private func grantInputMonitoring() {
        PermissionsService.openInputMonitoringSettings()
    }

    // MARK: - Settings window (bypasses SwiftUI Settings scene)
    // Using NSHostingController directly avoids the LSUIElement + Settings scene
    // incompatibility where sendAction("showSettingsWindow:") silently no-ops.

    @objc private func openPreferences() {
        if let existing = settingsWindowController, let win = existing.window, win.isVisible {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            win.makeKeyAndOrderFront(nil)
            return
        }

        // Build settings window fresh each time if not already visible.
        let rootView = SettingsView().environmentObject(viewModel)
        let hostingController = NSHostingController(rootView: rootView)

        let window = NSWindow(contentViewController: hostingController)
        window.title      = "OverKeys Preferences"
        window.styleMask  = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 520, height: 470))
        window.center()
        window.isReleasedWhenClosed = false // keep for reuse

        let wc = NSWindowController(window: window)
        wc.window?.delegate = self
        settingsWindowController = wc

        // Must switch to .regular and activate so the window becomes key.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        wc.showWindow(nil)
        window.makeKeyAndOrderFront(nil)
    }
}

// MARK: - NSWindowDelegate — revert to accessory when settings closes

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard (notification.object as? NSWindow) === settingsWindowController?.window else { return }
        // Give the window time to close before reverting, otherwise it glitches.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
