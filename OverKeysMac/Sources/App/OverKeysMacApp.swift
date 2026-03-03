// OverKeysMacApp.swift

import SwiftUI

@main
struct OverKeysMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // A Settings scene is required for @main to initialise the run loop.
        // We suppress the auto-generated Preferences menu item by handling
        // Preferences ourselves from the status-bar menu (AppDelegate.openPreferences).
        // This scene intentionally renders nothing.
        Settings {
            EmptyView()
        }
    }
}
