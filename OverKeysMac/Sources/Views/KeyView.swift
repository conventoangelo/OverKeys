// KeyView.swift
// Renders a single keyboard key with press animation.

import SwiftUI

struct KeyView: View {

    let keyID:     String   // canonical key label from layout
    let isPressed: Bool
    let prefs:     AppPreferences
    /// Non-nil when the active Glove80 layer maps this position to a different key.
    /// Shown instead of the base label, with the overlay background color.
    var overlayLabel: String? = nil
    /// Small corner badge showing the Symbol layer mapping for this key position.
    var secondaryLabel: String? = nil

    // MARK: - Derived display label

    /// The effective key ID to display — overlay label when present, otherwise base.
    private var effectiveKeyID: String { overlayLabel ?? keyID }

    private var displayLabel: String { Self.transformLabel(effectiveKeyID) }
    private var badgeLabel: String? {
        guard let raw = secondaryLabel else { return nil }
        return Self.transformLabel(raw)
    }

    /// Canonical label transform shared by primary and badge labels.
    private static func transformLabel(_ id: String) -> String {
        switch id.uppercased() {
        case " ", "SPC", "SPACE": return ""   // space key intentionally blank
        case "BSPC":              return "⌫"
        case "ENTER", "RETURN":   return "↵"
        case "TAB":               return "⇥"
        case "CAPS":              return "⇪"
        case "LSFT":              return "⇧"
        case "RSFT":              return "⇧"
        case "LCTRL", "RCTRL":   return "⌃"
        case "LALT", "RALT":     return "⌥"
        case "WIN", "CMD":        return "⌘"
        case "FN":                return "fn"
        case "ESC":               return "esc"
        case "DEL":               return "⌦"
        case "PGUP":              return "PgUp"
        case "PGDN":              return "PgDn"
        case "HOME":              return "Home"
        case "END":               return "End"
        case "INS":               return "Ins"
        default:                  return id
        }
    }

    // MARK: - Geometry

    private var widthMultiplier: CGFloat {
        // Glove80 is a columnar keyboard — every key is 1U
        if prefs.keymapStyle == .glove80 { return 1.0 }
        return KeyboardLayout.widthMultiplier(for: keyID)
    }

    private var keyWidth: CGFloat {
        CGFloat(prefs.keySize) * widthMultiplier
    }

    private var keyHeight: CGFloat {
        CGFloat(prefs.keySize)
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        if isPressed           { return prefs.keyPressedColor.color }
        if overlayLabel != nil { return prefs.layerOverlayColor.color }
        return prefs.keyColor.color
    }

    private var textColor: Color {
        isPressed
            ? prefs.textPressedColor.color
            : prefs.textColor.color
    }

    private var borderColor: Color {
        isPressed
            ? prefs.borderPressedColor.color
            : prefs.borderColor.color
    }

    // MARK: - Animation scale / offset

    @State private var animScale:  CGFloat = 1.0
    @State private var animOffset: CGFloat = 0.0

    // MARK: - Body

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CGFloat(prefs.borderRadius))
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(prefs.borderRadius))
                        .strokeBorder(borderColor, lineWidth: CGFloat(prefs.borderThickness))
                )
                .shadow(
                    color: .black.opacity(0.4),
                    radius: CGFloat(prefs.shadowBlur),
                    x:     CGFloat(prefs.shadowOffsetX),
                    y:     CGFloat(prefs.shadowOffsetY)
                )

            Text(displayLabel)
                .font(.custom(prefs.fontFamily, size: labelFontSize))
                .foregroundColor(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)

            // Symbol layer corner badge
            if let badge = badgeLabel, !badge.isEmpty, overlayLabel == nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(badge)
                            .font(.custom(prefs.fontFamily, size: CGFloat(prefs.symbolBadgeFontSize)))
                            .foregroundColor(prefs.symbolBadgeColor.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .allowsTightening(true)
                            .padding(.trailing, 3)
                            .padding(.bottom, 2)
                    }
                }
            }
        }
        .frame(width: keyWidth, height: keyHeight)
        .scaleEffect(animScale)
        .offset(y: animOffset)
        .onChange(of: isPressed, perform: { pressed in
            applyAnimation(pressed: pressed)
        })
    }

    // MARK: - Font size by key type

    private var labelFontSize: CGFloat {
        let isSpace = keyID == " " || keyID.uppercased() == "SPC" || keyID.uppercased() == "SPACE"
        return CGFloat(isSpace ? prefs.spaceFontSize : prefs.keyFontSize)
    }

    // MARK: - Press animation

    private func applyAnimation(pressed: Bool) {
        guard prefs.animationsEnabled else { return }
        let dur = prefs.animationDuration

        withAnimation(.easeOut(duration: dur)) {
            switch prefs.animationStyle {
            case .depress:
                animOffset = pressed ?  2 : 0
                animScale  = pressed ? (1 / prefs.animationScale) : 1
            case .raise:
                animOffset = pressed ? -2 : 0
                animScale  = pressed ? prefs.animationScale : 1
            case .grow:
                animScale  = pressed ? prefs.animationScale : 1
                animOffset = 0
            case .shrink:
                animScale  = pressed ? (1 / prefs.animationScale) : 1
                animOffset = 0
            }
        }
    }
}

#Preview {
    HStack(spacing: 4) {
        KeyView(keyID: "A",   isPressed: false, prefs: AppPreferences())
        KeyView(keyID: "S",   isPressed: true,  prefs: AppPreferences())
        KeyView(keyID: "TAB", isPressed: false, prefs: AppPreferences())
    }
    .padding()
    .background(Color.black)
}
