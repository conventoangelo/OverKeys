// SettingsView.swift
// Full preferences window — mirrors OverKeys' tab structure.
// Requires macOS 13+.

import SwiftUI
import AppKit

struct SettingsView: View {

    @EnvironmentObject var viewModel: KeyboardViewModel

    var body: some View {
        TabView {
            GeneralTab()
                .tabItem { Label("General", systemImage: "gearshape") }
                .environmentObject(viewModel)

            KeyboardTab()
                .tabItem { Label("Keyboard", systemImage: "keyboard") }
                .environmentObject(viewModel)

            ColorsTab()
                .tabItem { Label("Colors", systemImage: "paintpalette") }
                .environmentObject(viewModel)

            TextTab()
                .tabItem { Label("Text", systemImage: "textformat") }
                .environmentObject(viewModel)

            AnimationsTab()
                .tabItem { Label("Animations", systemImage: "sparkles") }
                .environmentObject(viewModel)

            AdvancedTab()
                .tabItem { Label("Advanced", systemImage: "wrench.and.screwdriver") }
                .environmentObject(viewModel)

            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 520, height: 460)
    }
}

// MARK: - General Tab

private struct GeneralTab: View {
    @EnvironmentObject var vm: KeyboardViewModel

    var body: some View {
        Form {
            Section("Overlay") {
                Toggle("Always on Top",      isOn: binding(\.alwaysOnTop))
                Toggle("Click-through",      isOn: binding(\.clickThrough))
                Toggle("Show on All Spaces", isOn: binding(\.showOnAllSpaces))

                HStack {
                    Text("Opacity")
                    Slider(value: binding(\.opacity), in: 0.1...1.0, step: 0.05)
                    Text("\(Int(vm.preferences.opacity * 100))%")
                        .monospacedDigit()
                        .frame(width: 40)
                }

                Picker("Monitor", selection: Binding<Int>(
                    get: { 0 },
                    set: { vm.overlayWindowController?.moveToScreen(at: $0) }
                )) {
                    ForEach(NSScreen.screens.indices, id: \.self) { i in
                        Text(NSScreen.screens[i].localizedName).tag(i)
                    }
                }
            }

            Section("Behaviour") {
                Toggle("Auto-hide", isOn: binding(\.autoHide))

                if vm.preferences.autoHide {
                    HStack {
                        Text("Hide after")
                        Slider(value: binding(\.autoHideDuration), in: 0.5...5.0, step: 0.5)
                        Text("\(vm.preferences.autoHideDuration, specifier: "%.1f")s")
                            .monospacedDigit()
                            .frame(width: 35)
                    }
                }

                Toggle("Reactive Shift", isOn: binding(\.reactiveShift))
                // Launch at login — uses the binding change notification
                Toggle("Launch at Startup", isOn: binding(\.launchAtStartup))
            }

            Section("Layout") {
                Picker("Active Layout", selection: Binding<String>(
                    get: { vm.activeLayout.name },
                    set: { name in
                        if let layout = KeyboardLayout.find(named: name, in: vm.userConfig.userLayouts) {
                            vm.setLayout(layout)
                        }
                    }
                )) {
                    ForEach(vm.userConfig.allLayouts) { layout in
                        Text(layout.name).tag(layout.name)
                    }
                }
            }

            Section("Permissions") {
                PermissionStatusRow(
                    label: "Accessibility",
                    status: vm.accessibilityStatus,
                    onGrant: { PermissionsService.openAccessibilitySettings() }
                )
                PermissionStatusRow(
                    label: "Input Monitoring",
                    status: vm.inputMonitoringStatus,
                    onGrant: { PermissionsService.openInputMonitoringSettings() }
                )
                Button("Retry Permission Detection") {
                    vm.checkPermissions()
                    if vm.hasRequiredPermissions && !vm.isCaptureActive {
                        vm.startCapture()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // Fix: use explicit `newValue` to avoid $0/$1 capture ambiguity
    private func binding<V>(_ kp: WritableKeyPath<AppPreferences, V>) -> Binding<V> {
        Binding(
            get: { vm.preferences[keyPath: kp] },
            set: { newValue in vm.updatePreferences { $0[keyPath: kp] = newValue } }
        )
    }
}

// MARK: - Keyboard Tab

private struct KeyboardTab: View {
    @EnvironmentObject var vm: KeyboardViewModel

    var body: some View {
        Form {
            Section("Style") {
                Picker("Keymap Style", selection: binding(\.keymapStyle)) {
                    ForEach(KeymapStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                Toggle("Show Top Row",   isOn: binding(\.showTopRow))
                Toggle("Show Grave Key", isOn: binding(\.showGraveKey))
            }

            Section("Key Size") {
                numericRow("Key Size",       kp: \.keySize,          range: 24...80)
                numericRow("Border Radius",  kp: \.borderRadius,     range: 0...20)
                numericRow("Border Width",   kp: \.borderThickness,  range: 0...4)
                numericRow("Key Padding",    kp: \.keyPadding,       range: 1...12)
                numericRow("Space Width ×",  kp: \.spaceWidth,       range: 2...10)
            }

            Section("Shadows") {
                numericRow("Blur",     kp: \.shadowBlur,    range: 0...20)
                numericRow("Offset X", kp: \.shadowOffsetX, range: -10...10)
                numericRow("Offset Y", kp: \.shadowOffsetY, range: -10...10)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func binding<V>(_ kp: WritableKeyPath<AppPreferences, V>) -> Binding<V> {
        Binding(
            get: { vm.preferences[keyPath: kp] },
            set: { newValue in vm.updatePreferences { $0[keyPath: kp] = newValue } }
        )
    }

    @ViewBuilder
    private func numericRow(_ label: String,
                             kp: WritableKeyPath<AppPreferences, Double>,
                             range: ClosedRange<Double>) -> some View {
        LabeledContent(label) {
            HStack {
                Slider(value: binding(kp), in: range)
                Text("\(vm.preferences[keyPath: kp], specifier: "%.1f")")
                    .monospacedDigit()
                    .frame(width: 40)
            }
        }
    }
}

// MARK: - Colors Tab

private struct ColorsTab: View {
    @EnvironmentObject var vm: KeyboardViewModel

    var body: some View {
        Form {
            colorRow("Key (default)",    \.keyColor)
            colorRow("Key (pressed)",    \.keyPressedColor)
            colorRow("Text (default)",   \.textColor)
            colorRow("Text (pressed)",   \.textPressedColor)
            colorRow("Border (default)", \.borderColor)
            colorRow("Border (pressed)", \.borderPressedColor)
        }
        .formStyle(.grouped)
        .padding()
    }

    @ViewBuilder
    private func colorRow(_ label: String,
                           _ kp: WritableKeyPath<AppPreferences, StoredColor>) -> some View {
        LabeledContent(label) {
            ColorPicker("", selection: Binding<Color>(
                get: { vm.preferences[keyPath: kp].color },
                set: { newColor in vm.updatePreferences { $0[keyPath: kp] = StoredColor(newColor) } }
            ), supportsOpacity: true)
            .labelsHidden()
        }
    }
}

// MARK: - Text Tab

private struct TextTab: View {
    @EnvironmentObject var vm: KeyboardViewModel

    private let fonts   = ["DM Mono", "SF Mono", "Menlo", "Courier New", "Monaco",
                            "Helvetica Neue", "Arial", "Manrope"]
    private let weights = ["Thin", "Light", "Regular", "Medium", "SemiBold", "Bold"]

    var body: some View {
        Form {
            Picker("Font Family", selection: Binding<String>(
                get: { vm.preferences.fontFamily },
                set: { v in vm.updatePreferences { $0.fontFamily = v } }
            )) {
                ForEach(fonts, id: \.self) { f in
                    Text(f).font(.custom(f, size: 13)).tag(f)
                }
            }

            Picker("Font Weight", selection: Binding<String>(
                get: { vm.preferences.fontWeight },
                set: { v in vm.updatePreferences { $0.fontWeight = v } }
            )) {
                ForEach(weights, id: \.self) { Text($0).tag($0) }
            }

            LabeledContent("Key Font Size") {
                HStack {
                    Slider(value: Binding<Double>(
                        get: { vm.preferences.keyFontSize },
                        set: { v in vm.updatePreferences { $0.keyFontSize = v } }
                    ), in: 8...28)
                    Text("\(Int(vm.preferences.keyFontSize))pt")
                        .monospacedDigit().frame(width: 40)
                }
            }

            Section("Symbol Layer Badge") {
                Toggle("Show Symbol Badge", isOn: Binding<Bool>(
                    get: { vm.preferences.showSymbolBadge },
                    set: { v in vm.updatePreferences { $0.showSymbolBadge = v } }
                ))

                if vm.preferences.showSymbolBadge {
                    LabeledContent("Badge Font Size") {
                        HStack {
                            Slider(value: Binding<Double>(
                                get: { vm.preferences.symbolBadgeFontSize },
                                set: { v in vm.updatePreferences { $0.symbolBadgeFontSize = v } }
                            ), in: 4...28)
                            Text("\(Int(vm.preferences.symbolBadgeFontSize))pt")
                                .monospacedDigit().frame(width: 40)
                        }
                    }

                    LabeledContent("Badge Color") {
                        ColorPicker("", selection: Binding<Color>(
                            get: { vm.preferences.symbolBadgeColor.color },
                            set: { c in vm.updatePreferences { $0.symbolBadgeColor = StoredColor(c) } }
                        ), supportsOpacity: false)
                        .labelsHidden()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Animations Tab

private struct AnimationsTab: View {
    @EnvironmentObject var vm: KeyboardViewModel

    var body: some View {
        Form {
            Toggle("Enable Animations", isOn: Binding<Bool>(
                get: { vm.preferences.animationsEnabled },
                set: { v in vm.updatePreferences { $0.animationsEnabled = v } }
            ))

            if vm.preferences.animationsEnabled {
                Picker("Style", selection: Binding<AnimationStyle>(
                    get: { vm.preferences.animationStyle },
                    set: { v in vm.updatePreferences { $0.animationStyle = v } }
                )) {
                    ForEach(AnimationStyle.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }

                LabeledContent("Duration") {
                    HStack {
                        Slider(value: Binding<Double>(
                            get: { vm.preferences.animationDuration * 1000 },
                            set: { v in vm.updatePreferences { $0.animationDuration = v / 1000 } }
                        ), in: 20...300)
                        Text("\(Int(vm.preferences.animationDuration * 1000))ms")
                            .monospacedDigit().frame(width: 45)
                    }
                }

                LabeledContent("Scale") {
                    HStack {
                        Slider(value: Binding<Double>(
                            get: { vm.preferences.animationScale },
                            set: { v in vm.updatePreferences { $0.animationScale = v } }
                        ), in: 1.0...2.0)
                        Text("\(vm.preferences.animationScale, specifier: "%.2f")×")
                            .monospacedDigit().frame(width: 50)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Advanced Tab

private struct AdvancedTab: View {
    @EnvironmentObject var vm: KeyboardViewModel

    var body: some View {
        Form {
            Section("Layouts") {
                Toggle("Use User Layouts", isOn: Binding<Bool>(
                    get: { vm.preferences.useUserLayouts },
                    set: { v in vm.updatePreferences { $0.useUserLayouts = v }; vm.reloadConfig() }
                ))
                Toggle("Show Alt Layout", isOn: Binding<Bool>(
                    get: { vm.preferences.showAltLayout },
                    set: { v in vm.updatePreferences { $0.showAltLayout = v } }
                ))
                Toggle("6-Column Layout", isOn: Binding<Bool>(
                    get: { vm.preferences.use6ColLayout },
                    set: { v in vm.updatePreferences { $0.use6ColLayout = v } }
                ))
            }

            Section("Kanata Integration") {
                Toggle("Connect to Kanata", isOn: Binding<Bool>(
                    get: { vm.preferences.useKanata },
                    set: { v in vm.updatePreferences { $0.useKanata = v } }
                ))
                if vm.preferences.useKanata {
                    TextField("Host", text: Binding<String>(
                        get: { vm.preferences.kanataHost },
                        set: { v in vm.updatePreferences { $0.kanataHost = v } }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }

            Section("Config File") {
                HStack {
                    Button("Open Config File") { ConfigService.openInEditor() }
                    Button("Show in Finder")   { ConfigService.revealInFinder() }
                    Button("Reload Config")    { vm.reloadConfig() }
                }
                Text(ConfigService.configURL.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About Tab

private struct AboutTab: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("OverKeys for macOS")
                .font(.largeTitle.bold())
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                .foregroundStyle(.secondary)

            Divider()

            Text("A native macOS keyboard overlay visualizer.\nHighlights keys in real time as you type.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Link("GitHub Repository",
                 destination: URL(string: "https://github.com/conventoangelo/OverKeys")!)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Permission status row helper

private struct PermissionStatusRow: View {
    let label:   String
    let status:  PermissionStatus
    let onGrant: () -> Void

    var body: some View {
        HStack {
            Circle()
                .fill(status == .granted ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(label)
            Spacer()
            if status != .granted {
                Button("Open Settings", action: onGrant)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            } else {
                Text("Granted").foregroundStyle(.green).font(.caption)
            }
        }
    }
}

// MARK: - Launch-at-login stub

private enum StartupService {
    static func setLaunchAtLogin(_ enabled: Bool) {
        // Add ServiceManagement.framework, then:
        //   if #available(macOS 13, *) {
        //     if enabled { try? SMAppService.mainApp.register()   }
        //     else       { try? SMAppService.mainApp.unregister() }
        //   }
        _ = enabled
    }
}

// MARK: - OverlayWindowController accessor

extension KeyboardViewModel {
    var overlayWindowController: OverlayWindowController? {
        (NSApplication.shared.delegate as? AppDelegate)?.overlayWindowController
    }
}
