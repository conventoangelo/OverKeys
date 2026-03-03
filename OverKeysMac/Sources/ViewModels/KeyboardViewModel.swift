// KeyboardViewModel.swift
// Central observable state for the keyboard overlay.
// Coordinates EventTapService, ConfigService, and all UI bindings.

import SwiftUI
import Combine

final class KeyboardViewModel: ObservableObject {

    // MARK: Published state — drives the overlay

    @Published var pressedKeys:    Set<String>      = []
    @Published var activeLayout:   KeyboardLayout   = .qwerty
    @Published var altLayout:      KeyboardLayout?  = nil
    @Published var preferences:    AppPreferences   = AppPreferences.load()
    @Published var userConfig:     UserConfig       = ConfigService.load()

    // MARK: Permission & capture state

    @Published var accessibilityStatus: PermissionStatus = .unknown
    @Published var inputMonitoringStatus: PermissionStatus = .unknown
    @Published var isCaptureActive: Bool = false

    // MARK: Overlay visibility

    @Published var isOverlayVisible: Bool = true

    // MARK: Layer overlay (Glove80 diff display)
    // When keymapStyle == .glove80 and a held layer is active, this carries the
    // layer definition while activeLayout stays as the base. KeyboardView diffs
    // the two and highlights only the keys that change in the active layer.
    @Published var layerOverlay: KeyboardLayout? = nil

    /// TK Symbol layer from user config (for corner badge display on base overlay).
    var symbolLayer: KeyboardLayout? {
        userConfig.userLayouts.first { $0.name == "TK Symbol" }
    }

    // MARK: Layer stack (for held/toggled layers)

    private var layerStack: [KeyboardLayout] = []
    private var heldLayerKey: String? = nil

    // MARK: Layer auto-inference
    // When a key unique to a specific layer is pressed (e.g. arrows on Nav) but no
    // explicit trigger was received (ZMK hold fired before the keycode arrived),
    // infer the active layer and show the overlay briefly.

    private var inferenceTimer: Timer?
    private var _cachedInferenceMap: [String: KeyboardLayout]?
    private var isOverlayInferred = false

    // MARK: Toggle / tap timing
    // Firmware may send trigger key taps (plain or with Hyper) on both thumb-down
    // and thumb-up. Track timing for deferred-off and quick-tap detection.
    private var overlayToggleTime: Date = .distantPast
    private var deferredOffTimer: Timer?
    private var lastTriggerDownTime: Date = .distantPast

    // MARK: Hold-to-peek layer overlay
    // Hold a thumb key (BSPC, SPC, ENTER) to peek at the corresponding layer.
    // Shows overlay on keyDown, hides on keyUp.
    private var peekOverlayKey: String?
    /// Maps thumb-key tap labels → layer names for hold-to-peek.
    private let peekLayerMap: [String: String] = [
        "BSPC":  "TK Cursor",
        " ":     "TK Symbol",
        "ENTER": "TK Mouse",
    ]

    // MARK: Auto-hide

    private var autoHideTimer: Timer?

    // MARK: Services

    private let eventTap   = EventTapService()
    private var keyCodeCustomMap: [CGKeyCode: String] = [:]

    // MARK: Init

    init() {
        applyConfig(userConfig)
        wireEventTap()
    }

    // MARK: - Permissions

    func checkPermissions() {
        accessibilityStatus     = PermissionsService.accessibilityStatus()
        inputMonitoringStatus   = PermissionsService.inputMonitoringStatus()
    }

    var hasRequiredPermissions: Bool {
        accessibilityStatus == .granted && inputMonitoringStatus != .denied
    }

    // MARK: - Capture lifecycle

    func startCapture() {
        guard !isCaptureActive else { return }
        // Always attempt — if Accessibility is missing, CGEventTapCreate fails
        // and EventTapService calls onPermissionDenied, which resets isCaptureActive.
        eventTap.start()
        isCaptureActive = true
    }

    func stopCapture() {
        guard isCaptureActive else { return }
        eventTap.stop()
        isCaptureActive = false
        pressedKeys.removeAll()
    }

    // MARK: - Config

    func reloadConfig() {
        let config = ConfigService.load()
        userConfig = config
        applyConfig(config)
    }

    func saveConfig() {
        try? ConfigService.save(userConfig)
    }

    private func applyConfig(_ config: UserConfig) {
        // Resolve active layout
        if preferences.useUserLayouts, let name = config.defaultUserLayout {
            activeLayout = config.resolveLayout(named: name)
        }
        // Resolve alt layout
        if let altName = config.altLayout {
            altLayout = config.resolveLayout(named: altName)
        }
        // Custom key code overrides
        keyCodeCustomMap = [:]
        for (hexStr, label) in config.customKeys {
            if let code = UInt16(hexStr.replacingOccurrences(of: "0x", with: ""), radix: 16) {
                keyCodeCustomMap[CGKeyCode(code)] = label
            }
        }
        // Invalidate inference cache whenever config reloads
        _cachedInferenceMap = nil
    }

    // MARK: - Event tap wiring

    private func wireEventTap() {
        eventTap.onKeyDown = { [weak self] keyCode, flags in
            self?.handleKeyDown(keyCode: keyCode, flags: flags)
        }
        eventTap.onKeyUp = { [weak self] keyCode, flags in
            self?.handleKeyUp(keyCode: keyCode)
        }
        eventTap.onFlagsChanged = { [weak self] keyCode, flags in
            self?.handleFlagsChanged(keyCode: keyCode, flags: flags)
        }
        eventTap.onPermissionDenied = { [weak self] in
            self?.isCaptureActive = false
            self?.checkPermissions()
        }
    }

    // MARK: - Key event handling

    private func handleKeyDown(keyCode: CGKeyCode, flags: CGEventFlags) {
        let label = KeyMapping.label(for: keyCode, custom: keyCodeCustomMap)
        let isHyper = isHyperModifier(flags)

        // Diagnostic: log any key that matches a layer trigger, with modifier details
        if findLayerTrigger(label) != nil {
            let mods = [
                flags.contains(.maskCommand)   ? "Cmd" : nil,
                flags.contains(.maskAlternate)  ? "Alt" : nil,
                flags.contains(.maskControl)    ? "Ctrl" : nil,
                flags.contains(.maskShift)      ? "Shift" : nil,
            ].compactMap { $0 }.joined(separator: "+")
            fputs("[Layers] trigger key \"\(label)\" (code \(keyCode)) flags=[\(mods)] isHyper=\(isHyper)\n", stderr)
        }

        // Layer switching FIRST — before ignoredKeys so Fx trigger keycodes
        // (which are in ignoredKeys to suppress display) still activate layers.
        if let layerTrigger = findLayerTrigger(label) {
            if isHyper {
                // Hyper+key tap pattern: toggle layer overlay
                toggleLayerOverlay(layerTrigger)
                return
            } else if userConfig.ignoredKeys.contains(label) {
                // Plain trigger (F-key in ignoredKeys) — TailorKey model.
                // Supports both sustained hold AND tap-twice:
                // • Sustained hold: activate on keyDown, deactivate on keyUp
                // • Tap-twice: first tap ON (quick keyUp converts to toggle),
                //   second tap OFF
                if layerOverlay?.name == layerTrigger.name
                    && heldLayerKey == nil
                    && !isOverlayInferred {
                    // Overlay is already active via toggle → second tap = OFF
                    fputs("[Layers] second tap \"\(label)\" → overlay OFF (was \"\(layerTrigger.name)\")\n", stderr)
                    layerOverlay = nil
                    isOverlayInferred = false
                } else {
                    activateLayer(layerTrigger, triggerLabel: label)
                    lastTriggerDownTime = Date()
                }
                return
            }
            // Regular key that happens to match a trigger (e.g. "=" without Hyper)
            // → fall through to normal key handling
        }

        // Ignored keys (checked after trigger so triggers always work)
        if userConfig.ignoredKeys.contains(label) { return }

        // Hold-to-peek: pressing a thumb key (BSPC/SPC/ENTER) immediately
        // shows the corresponding layer overlay. Released in handleKeyUp.
        if preferences.keymapStyle == .glove80, let layerName = peekLayerMap[label] {
            if let layer = userConfig.userLayouts.first(where: { $0.name == layerName }) {
                fputs("[Layers] peek \"\(label)\" → showing \"\(layerName)\"\n", stderr)
                layerOverlay = layer
                isOverlayInferred = false
                peekOverlayKey = label
            }
        }

        // Resolve display label (alias / shift)
        let displayLabel = resolveDisplayLabel(label, flags: flags)
        pressedKeys.insert(displayLabel)
        fputs("[Keys] pressed=\(pressedKeys) insert=\"\(displayLabel)\" visible=\(isOverlayVisible)\n", stderr)
        resetAutoHideTimer()

        // Infer layer from unique keys when no explicit signal was received.
        // Try raw label first (e.g. "←" for arrow keys), then also try the
        // shifted label (e.g. "!" when ZMK sends Shift+1 for the Symbol layer).
        // This is independent of the reactiveShift display preference.
        tryInferLayer(from: label)
        if flags.contains(.maskShift) {
            if let shifted = KeyMapping.shiftedLabel(for: label, custom: userConfig.customShiftMappings),
               shifted != label {
                tryInferLayer(from: shifted)
            }
        }

        // Diagnostic: overlay state after processing
        if layerOverlay != nil {
            fputs("[Layers] overlay=\(layerOverlay!.name) inferred=\(isOverlayInferred) held=\(heldLayerKey ?? "nil")\n", stderr)
        }
    }

    private func handleKeyUp(keyCode: CGKeyCode) {
        let label = KeyMapping.label(for: keyCode, custom: keyCodeCustomMap)

        // Peek overlay release — hide layer when thumb key is released
        if let peekKey = peekOverlayKey, peekKey == label {
            fputs("[Layers] peek release \"\(label)\" → overlay OFF\n", stderr)
            peekOverlayKey = nil
            // Only clear overlay if inference hasn't taken over
            if !isOverlayInferred {
                layerOverlay = nil
            }
            // Don't return — still need to remove from pressedKeys below
        }

        // Held layer release
        if let heldKey = heldLayerKey, heldKey == label {
            let elapsed = Date().timeIntervalSince(lastTriggerDownTime)
            if elapsed < 0.05 {
                // Quick tap (< 50ms) — firmware sent a brief signal (tap-twice pattern).
                // Convert to toggle: keep overlay active, clear held state so keyUp
                // won't deactivate. The second tap will toggle it off.
                fputs("[Layers] quick tap \"\(label)\" (\(Int(elapsed * 1000))ms) → keeping overlay as toggle\n", stderr)
                heldLayerKey = nil
            } else {
                // Sustained hold release — deactivate normally
                deactivateHeldLayer()
            }
            return
        }

        let displayLabel = resolveDisplayLabel(label, flags: [])
        pressedKeys.remove(displayLabel)
        // Also remove un-shifted variant in case shift was released before key
        pressedKeys.remove(label)
    }

    private func handleFlagsChanged(keyCode: CGKeyCode, flags: CGEventFlags) {
        guard let modLabel = KeyMapping.modifierLabel(for: keyCode) else { return }

        let isDown = isModifierDown(keyCode: keyCode, flags: flags)
        if isDown {
            pressedKeys.insert(modLabel)
        } else {
            pressedKeys.remove(modLabel)
            // When shift is released, un-shift all currently-shown shifted keys
            if modLabel == "LSFT" || modLabel == "RSFT" {
                removeShiftedKeys()
            }
        }
    }

    /// Check if a modifier key is currently down from its flags.
    private func isModifierDown(keyCode: CGKeyCode, flags: CGEventFlags) -> Bool {
        switch keyCode {
        case VK.shift, VK.rightShift:
            return flags.contains(.maskShift)
        case VK.control, VK.rightControl:
            return flags.contains(.maskControl)
        case VK.option, VK.rightOption:
            return flags.contains(.maskAlternate)
        case VK.command, VK.rightCommand:
            return flags.contains(.maskCommand)
        case VK.capsLock:
            return flags.contains(.maskAlphaShift)
        case VK.function_key:
            return flags.contains(.maskSecondaryFn)
        default:
            return false
        }
    }

    // MARK: - Shift / alias resolution

    private func resolveDisplayLabel(_ label: String, flags: CGEventFlags) -> String {
        // Custom alias takes priority
        if let alias = userConfig.customAliases[label] {
            return alias.joined(separator: "+")
        }
        // Reactive shift
        if preferences.reactiveShift,
           flags.contains(.maskShift),
           let shifted = KeyMapping.shiftedLabel(for: label, custom: userConfig.customShiftMappings) {
            return shifted
        }
        return label
    }

    private func removeShiftedKeys() {
        let shiftedSet = Set(KeyMapping.defaultShiftMap.values)
        pressedKeys = pressedKeys.filter { !shiftedSet.contains($0) }
    }

    // MARK: - Layer management

    private func findLayerTrigger(_ label: String) -> KeyboardLayout? {
        // Layer triggers are checked regardless of the useUserLayouts display setting.
        // useUserLayouts only controls which layout is shown as the base; layer
        // switching must always work so Glove80 layers react to held keys.
        userConfig.userLayouts.first {
            guard let trigger = $0.trigger else { return false }
            return trigger.caseInsensitiveCompare(label) == .orderedSame
        }
    }

    private func activateLayer(_ layer: KeyboardLayout, triggerLabel: String) {
        fputs("[Layers] activating \"\(layer.name)\" via \"\(triggerLabel)\"\n", stderr)
        // Explicit activation takes priority over inference and deferred-off
        isOverlayInferred = false
        inferenceTimer?.invalidate()
        deferredOffTimer?.invalidate()
        deferredOffTimer = nil
        switch layer.type {
        case .held:
            if preferences.keymapStyle == .glove80 {
                // Glove80 diff mode: keep base layout, store layer for per-key highlighting
                layerOverlay = layer
                heldLayerKey = triggerLabel
            } else {
                layerStack.append(activeLayout)
                activeLayout = layer
                heldLayerKey = triggerLabel
            }

        case .toggle:
            if activeLayout.name == layer.name {
                // Toggle off — pop previous
                activeLayout = layerStack.popLast() ?? userConfig.resolveLayout(named: userConfig.defaultUserLayout)
            } else {
                layerStack.append(activeLayout)
                activeLayout = layer
            }
            heldLayerKey = nil

        case .none:
            break
        }
    }

    private func deactivateHeldLayer() {
        fputs("[Layers] deactivating held layer\n", stderr)
        if layerOverlay != nil {
            // Glove80 diff mode — just clear the overlay, base layout unchanged
            layerOverlay = nil
        } else {
            activeLayout = layerStack.popLast() ?? userConfig.resolveLayout(named: userConfig.defaultUserLayout)
        }
        heldLayerKey = nil
    }

    /// Detect Hyper modifier (Cmd+Alt+Ctrl+Shift all pressed simultaneously).
    /// Old Glove80 firmware sends Hyper+F-key taps to signal layer activation.
    private func isHyperModifier(_ flags: CGEventFlags) -> Bool {
        flags.contains(.maskCommand) && flags.contains(.maskAlternate) &&
        flags.contains(.maskControl) && flags.contains(.maskShift)
    }

    /// Toggle a layer overlay on/off via Hyper+key tap-twice pattern.
    /// First Hyper+key tap activates the overlay; second tap deactivates it.
    /// The firmware sends one tap on thumb-down and one on thumb-up. If the user
    /// taps quickly, both arrive within a single SwiftUI render cycle. We defer
    /// the OFF signal to guarantee the overlay is visible for at least 150 ms.
    private func toggleLayerOverlay(_ layer: KeyboardLayout) {
        isOverlayInferred = false  // explicit toggle, not inference
        let now = Date()

        if preferences.keymapStyle == .glove80 {
            if layerOverlay?.name == layer.name {
                // Deactivate — but not if we just activated (< 150 ms ago)
                let elapsed = now.timeIntervalSince(overlayToggleTime)
                if elapsed < 0.15 {
                    fputs("[Layers] overlay OFF deferred (\(Int(elapsed * 1000))ms since ON)\n", stderr)
                    deferredOffTimer?.invalidate()
                    deferredOffTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in
                        guard let self, let current = self.layerOverlay else { return }
                        fputs("[Layers] overlay OFF (was \"\(current.name)\") [deferred]\n", stderr)
                        self.layerOverlay = nil
                    }
                    return
                }
                layerOverlay = nil
                fputs("[Layers] overlay OFF (was \"\(layer.name)\")\n", stderr)
            } else {
                deferredOffTimer?.invalidate()  // cancel any pending OFF from a previous layer
                deferredOffTimer = nil
                layerOverlay = layer
                overlayToggleTime = now
                fputs("[Layers] overlay ON \"\(layer.name)\"\n", stderr)
            }
        } else {
            // Non-Glove80: toggle activeLayout
            if activeLayout.name == layer.name {
                activeLayout = layerStack.popLast() ?? userConfig.resolveLayout(named: userConfig.defaultUserLayout)
                fputs("[Layers] overlay OFF (was \"\(layer.name)\")\n", stderr)
            } else {
                layerStack.append(activeLayout)
                activeLayout = layer
                fputs("[Layers] overlay ON \"\(layer.name)\"\n", stderr)
            }
        }
        // Don't set heldLayerKey — toggle, not hold
    }

    // MARK: - Layer auto-inference

    /// Builds (and caches) a map from label → the first user layer whose keys
    /// contain that label but the Glove80 base layout does NOT.
    /// Only relevant in Glove80 mode.
    private var inferenceMap: [String: KeyboardLayout] {
        if let cached = _cachedInferenceMap { return cached }
        guard preferences.keymapStyle == .glove80 else {
            _cachedInferenceMap = [:]
            return [:]
        }
        let baseLabels = Set(KeyboardLayout.glove80.keys.flatMap { $0 }.filter { !$0.isEmpty })
        // Navigation keys that appear on both base and layers (e.g. ↑/↓ on base row 4
        // AND TK Cursor). We still want these to trigger inference for their layer.
        let sharedNavKeys: Set<String> = ["↑", "↓", "←", "→", "PGUP", "PGDN", "HOME", "END"]
        var map: [String: KeyboardLayout] = [:]
        for layer in userConfig.userLayouts {
            // Only consider layers that have a trigger (real switchable layers)
            guard layer.trigger != nil else { continue }
            // Skip non-Glove80 layouts (e.g. Extend) that have fewer than 7 rows.
            // Inferring from a 5-row layout corrupts the per-key overlay labels in
            // Glove80 mode, causing all keys to stop highlighting.
            guard layer.keys.count == 7 else { continue }
            for label in layer.keys.flatMap({ $0 }) where !label.isEmpty {
                let isUnique = !baseLabels.contains(label)
                let isSharedNav = sharedNavKeys.contains(label)
                if (isUnique || isSharedNav) && map[label] == nil {
                    map[label] = layer
                }
            }
        }
        _cachedInferenceMap = map
        fputs("[Layers] inferenceMap built: \(map.keys.sorted()) → \(Set(map.values.map(\.name)))\n", stderr)
        return map
    }

    /// If the pressed key is unique to one layer and no explicit layer hold or
    /// toggle is active, infer that layer as the overlay (Glove80 diff mode only).
    /// Once a layer is inferred, any key that exists on that layer keeps the
    /// overlay alive (not just unique keys), so ↑/↓ don't cause flicker.
    private func tryInferLayer(from label: String) {
        guard preferences.keymapStyle == .glove80 else { return }
        guard heldLayerKey == nil else { return }   // explicit hold takes priority
        // Don't override a toggle-activated overlay with inference
        if layerOverlay != nil && !isOverlayInferred { return }

        // If a layer is already inferred, check if this key exists on it — keep alive
        if isOverlayInferred, let current = layerOverlay {
            let layerLabels = Set(current.keys.flatMap { $0 }.filter { !$0.isEmpty })
            if layerLabels.contains(label) {
                fputs("[Layers] keep-alive \"\(label)\" on \"\(current.name)\"\n", stderr)
                scheduleInferredOverlayClear()
                return
            }
        }

        guard let layer = inferenceMap[label] else { return }
        if layerOverlay?.name != layer.name {
            fputs("[Layers] inferred \"\(layer.name)\" from key \"\(label)\"\n", stderr)
            layerOverlay = layer
            isOverlayInferred = true
            // Diagnostic: dump overlay diff for right half
            let base = KeyboardLayout.glove80
            for rowIdx in 0..<min(layer.keys.count, base.keys.count) {
                let baseRow = base.keys[rowIdx]
                let overlayRow = layer.keys[rowIdx]
                let mid = baseRow.count / 2
                var diffs: [String] = []
                for col in mid..<baseRow.count {
                    let bk = baseRow[col]
                    let ok = col < overlayRow.count ? overlayRow[col] : ""
                    if !ok.isEmpty && ok != bk {
                        diffs.append("c\(col-mid):\(bk)→\(ok)")
                    }
                }
                if !diffs.isEmpty {
                    fputs("[Layers] RIGHT row\(rowIdx): \(diffs.joined(separator: " "))\n", stderr)
                }
            }
        }
        scheduleInferredOverlayClear()
    }

    /// Resets the inference timer so the overlay clears after the last
    /// unique-layer key is pressed. Only clears inference-activated overlays.
    private func scheduleInferredOverlayClear() {
        guard heldLayerKey == nil else { return }   // explicit hold manages its own lifecycle
        guard isOverlayInferred else { return }     // don't clear toggle-activated overlays
        inferenceTimer?.invalidate()
        inferenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self, self.heldLayerKey == nil, self.isOverlayInferred else { return }
            fputs("[Layers] inference cleared (timeout)\n", stderr)
            self.layerOverlay = nil
            self.isOverlayInferred = false
        }
    }

    // MARK: - Auto-hide

    private func resetAutoHideTimer() {
        guard preferences.autoHide else { return }
        autoHideTimer?.invalidate()
        isOverlayVisible = true
        autoHideTimer = Timer.scheduledTimer(
            withTimeInterval: preferences.autoHideDuration,
            repeats: false
        ) { [weak self] _ in
            withAnimation { self?.isOverlayVisible = false }
        }
    }

    // MARK: - Preferences helpers (called from Settings UI)

    func updatePreferences(_ block: (inout AppPreferences) -> Void) {
        block(&preferences)
        preferences.save()
    }

    func setLayout(_ layout: KeyboardLayout) {
        activeLayout = layout
        layerStack.removeAll()
    }
}
