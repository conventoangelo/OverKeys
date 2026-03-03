// AppPreferences.swift
// All user-tunable visual and behavioural preferences.
// Mirrors OverKeys' KeyboardState + PreferencesState combined.

import SwiftUI

// MARK: - Enums

enum KeymapStyle: String, Codable, CaseIterable {
    case staggered   = "Staggered"
    case matrix      = "Matrix"
    case splitMatrix = "Split Matrix"
    case glove80     = "Glove80"
}

enum AnimationStyle: String, Codable, CaseIterable {
    case depress = "Depress"
    case raise   = "Raise"
    case grow    = "Grow"
    case shrink  = "Shrink"
}

// MARK: - Color storage (Codable wrapper for SwiftUI Color)

struct StoredColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    var color: Color { Color(red: red, green: green, blue: blue, opacity: alpha) }
    var nsColor: NSColor { NSColor(red: red, green: green, blue: blue, alpha: alpha) }

    init(_ color: Color) {
        let resolved = NSColor(color).usingColorSpace(.deviceRGB) ?? .white
        self.red   = resolved.redComponent
        self.green = resolved.greenComponent
        self.blue  = resolved.blueComponent
        self.alpha = resolved.alphaComponent
    }

    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
    }

    static func hex(_ hex: UInt32, alpha: Double = 1) -> StoredColor {
        StoredColor(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >>  8) & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            alpha: alpha
        )
    }
}

// MARK: - AppPreferences

struct AppPreferences: Codable, Equatable {

    // MARK: Window / overlay
    var opacity: Double          = 0.90   // 0.1 – 1.0
    var alwaysOnTop: Bool        = true
    var clickThrough: Bool       = true
    var showOnAllSpaces: Bool    = true
    var windowX: Double          = 200
    var windowY: Double          = 100

    // MARK: Layout display
    var keymapStyle: KeymapStyle = .staggered
    var showTopRow: Bool         = true
    var showGraveKey: Bool       = true
    var showAltLayout: Bool      = false
    var useUserLayouts: Bool     = false
    var use6ColLayout: Bool      = false

    // MARK: Key geometry
    var keySize: Double          = 52     // base unit, pts
    var borderRadius: Double     = 6
    var borderThickness: Double  = 1
    var keyPadding: Double       = 4
    var spaceWidth: Double       = 6.25  // multiples of keySize
    var splitWidth: Double       = 20    // gap between halves (split matrix)

    // MARK: Key shadows
    var shadowBlur: Double       = 0
    var shadowOffsetX: Double    = 0
    var shadowOffsetY: Double    = 2

    // MARK: Typography
    var fontFamily: String       = "DM Mono"
    var fontWeight: String       = "Regular"
    var keyFontSize: Double      = 14
    var spaceFontSize: Double    = 10
    var symbolBadgeFontSize: Double = 8

    // MARK: Colors — default palette
    var keyColor: StoredColor           = .hex(0x2A2A2A)
    var keyPressedColor: StoredColor    = .hex(0x5865F2)   // Discord blurple
    var textColor: StoredColor          = .hex(0xEEEEEE)
    var textPressedColor: StoredColor   = .hex(0xFFFFFF)
    var borderColor: StoredColor        = .hex(0x444444)
    var borderPressedColor: StoredColor = .hex(0x7289DA)
    var markerColor: StoredColor        = .hex(0x888888)
    var markerPressedColor: StoredColor = .hex(0xFFFFFF)
    var layerOverlayColor: StoredColor  = .hex(0xD97706)   // amber — Glove80 diff keys
    var symbolBadgeColor: StoredColor   = .hex(0x06B6D4)   // teal — Symbol layer badge

    // MARK: Markers (finger-position dots)
    var markerOffset: Double     = 4
    var markerWidth: Double      = 6
    var markerHeight: Double     = 6
    var markerBorderRadius: Double = 3

    // MARK: Animations
    var animationsEnabled: Bool  = true
    var animationStyle: AnimationStyle = .depress
    var animationDuration: Double = 0.08   // seconds
    var animationScale: Double   = 1.15

    // MARK: Learning mode
    var learningModeEnabled: Bool = false
    var fingerColors: FingerColors = .defaults

    // MARK: App behaviour
    var launchAtStartup: Bool    = false
    var autoHide: Bool           = false
    var autoHideDuration: Double = 2.0
    var reactiveShift: Bool      = true   // show shifted labels when shift held
    var showSymbolBadge: Bool    = true   // show TK Symbol layer as corner badges

    // MARK: Kanata
    var useKanata: Bool          = false
    var kanataHost: String       = "127.0.0.1"
    var kanataPort: Int          = 4039
}

// MARK: - Finger Colors (Learning Mode)

struct FingerColors: Codable, Equatable {
    var leftPinky:  StoredColor
    var leftRing:   StoredColor
    var leftMiddle: StoredColor
    var leftIndex:  StoredColor
    var rightIndex: StoredColor
    var rightMiddle: StoredColor
    var rightRing:  StoredColor
    var rightPinky: StoredColor

    static let defaults = FingerColors(
        leftPinky:   .hex(0xFF6B6B),
        leftRing:    .hex(0xFFBE76),
        leftMiddle:  .hex(0xFECA57),
        leftIndex:   .hex(0x54A0FF),
        rightIndex:  .hex(0x5F27CD),
        rightMiddle: .hex(0x48DBFB),
        rightRing:   .hex(0x1DD1A1),
        rightPinky:  .hex(0xFF9FF3)
    )
}

// MARK: - Persistence

extension AppPreferences {
    static let userDefaultsKey = "OverKeysMac.AppPreferences"

    static func load() -> AppPreferences {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let prefs = try? JSONDecoder().decode(AppPreferences.self, from: data)
        else { return AppPreferences() }
        return prefs
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: AppPreferences.userDefaultsKey)
    }
}
