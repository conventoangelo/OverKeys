// KeyMapping.swift
// Maps macOS CGKeyCode values → canonical OverKeys key names.
// Sources: Carbon/HIToolbox/Events.h virtual key constants.

import CoreGraphics

// MARK: - CGKeyCode constants (mirrors kVK_* from Carbon)

enum VK {
    // Row 0 — numbers
    static let ansi_Grave        : CGKeyCode = 0x32  // `
    static let ansi_1            : CGKeyCode = 0x12
    static let ansi_2            : CGKeyCode = 0x13
    static let ansi_3            : CGKeyCode = 0x14
    static let ansi_4            : CGKeyCode = 0x15
    static let ansi_5            : CGKeyCode = 0x17
    static let ansi_6            : CGKeyCode = 0x16
    static let ansi_7            : CGKeyCode = 0x1A
    static let ansi_8            : CGKeyCode = 0x1C
    static let ansi_9            : CGKeyCode = 0x19
    static let ansi_0            : CGKeyCode = 0x1D
    static let ansi_Minus        : CGKeyCode = 0x1B
    static let ansi_Equal        : CGKeyCode = 0x18

    // Row 1 — QWERTY
    static let ansi_Q            : CGKeyCode = 0x0C
    static let ansi_W            : CGKeyCode = 0x0D
    static let ansi_E            : CGKeyCode = 0x0E
    static let ansi_R            : CGKeyCode = 0x0F
    static let ansi_T            : CGKeyCode = 0x11
    static let ansi_Y            : CGKeyCode = 0x10
    static let ansi_U            : CGKeyCode = 0x20
    static let ansi_I            : CGKeyCode = 0x22
    static let ansi_O            : CGKeyCode = 0x1F
    static let ansi_P            : CGKeyCode = 0x23
    static let ansi_LeftBracket  : CGKeyCode = 0x21
    static let ansi_RightBracket : CGKeyCode = 0x1E
    static let ansi_Backslash    : CGKeyCode = 0x2A

    // Row 2 — home row
    static let ansi_A            : CGKeyCode = 0x00
    static let ansi_S            : CGKeyCode = 0x01
    static let ansi_D            : CGKeyCode = 0x02
    static let ansi_F            : CGKeyCode = 0x03
    static let ansi_G            : CGKeyCode = 0x05
    static let ansi_H            : CGKeyCode = 0x04
    static let ansi_J            : CGKeyCode = 0x26
    static let ansi_K            : CGKeyCode = 0x28
    static let ansi_L            : CGKeyCode = 0x25
    static let ansi_Semicolon    : CGKeyCode = 0x29
    static let ansi_Quote        : CGKeyCode = 0x27

    // Row 3 — bottom row
    static let ansi_Z            : CGKeyCode = 0x06
    static let ansi_X            : CGKeyCode = 0x07
    static let ansi_C            : CGKeyCode = 0x08
    static let ansi_V            : CGKeyCode = 0x09
    static let ansi_B            : CGKeyCode = 0x0B
    static let ansi_N            : CGKeyCode = 0x2D
    static let ansi_M            : CGKeyCode = 0x2E
    static let ansi_Comma        : CGKeyCode = 0x2B
    static let ansi_Period       : CGKeyCode = 0x2F
    static let ansi_Slash        : CGKeyCode = 0x2C

    // Control / editing
    static let tab               : CGKeyCode = 0x30
    static let `return`          : CGKeyCode = 0x24
    static let space             : CGKeyCode = 0x31
    static let delete            : CGKeyCode = 0x33   // Backspace
    static let forwardDelete     : CGKeyCode = 0x75   // Del (fwd)
    static let escape            : CGKeyCode = 0x35
    static let help              : CGKeyCode = 0x72   // Insert on some boards
    static let capsLock          : CGKeyCode = 0x39

    // Modifiers
    static let shift             : CGKeyCode = 0x38
    static let rightShift        : CGKeyCode = 0x3C
    static let control           : CGKeyCode = 0x3B
    static let rightControl      : CGKeyCode = 0x3E
    static let option            : CGKeyCode = 0x3A   // Alt / Option
    static let rightOption       : CGKeyCode = 0x3D
    static let command           : CGKeyCode = 0x37   // ⌘ / Win
    static let rightCommand      : CGKeyCode = 0x36
    static let function_key      : CGKeyCode = 0x3F   // Fn

    // Navigation
    static let home              : CGKeyCode = 0x73
    static let end               : CGKeyCode = 0x77
    static let pageUp            : CGKeyCode = 0x74
    static let pageDown          : CGKeyCode = 0x79
    static let leftArrow         : CGKeyCode = 0x7B
    static let rightArrow        : CGKeyCode = 0x7C
    static let downArrow         : CGKeyCode = 0x7D
    static let upArrow           : CGKeyCode = 0x7E

    // Function keys
    static let f1                : CGKeyCode = 0x7A
    static let f2                : CGKeyCode = 0x78
    static let f3                : CGKeyCode = 0x63
    static let f4                : CGKeyCode = 0x76
    static let f5                : CGKeyCode = 0x60
    static let f6                : CGKeyCode = 0x61
    static let f7                : CGKeyCode = 0x62
    static let f8                : CGKeyCode = 0x64
    static let f9                : CGKeyCode = 0x65
    static let f10               : CGKeyCode = 0x6D
    static let f11               : CGKeyCode = 0x67
    static let f12               : CGKeyCode = 0x6F
    static let f13               : CGKeyCode = 0x69
    static let f14               : CGKeyCode = 0x6B
    static let f15               : CGKeyCode = 0x71
    static let f16               : CGKeyCode = 0x6A
    static let f17               : CGKeyCode = 0x40
    static let f18               : CGKeyCode = 0x4F
    static let f19               : CGKeyCode = 0x50
    static let f20               : CGKeyCode = 0x5A

    // Numpad
    static let kp_0              : CGKeyCode = 0x52
    static let kp_1              : CGKeyCode = 0x53
    static let kp_2              : CGKeyCode = 0x54
    static let kp_3              : CGKeyCode = 0x55
    static let kp_4              : CGKeyCode = 0x56
    static let kp_5              : CGKeyCode = 0x57
    static let kp_6              : CGKeyCode = 0x58
    static let kp_7              : CGKeyCode = 0x59
    static let kp_8              : CGKeyCode = 0x5B
    static let kp_9              : CGKeyCode = 0x5C
    static let kp_Decimal        : CGKeyCode = 0x41
    static let kp_Multiply       : CGKeyCode = 0x43
    static let kp_Plus           : CGKeyCode = 0x45
    static let kp_Clear          : CGKeyCode = 0x47
    static let kp_Divide         : CGKeyCode = 0x4B
    static let kp_Enter          : CGKeyCode = 0x4C
    static let kp_Minus          : CGKeyCode = 0x4E
    static let kp_Equals         : CGKeyCode = 0x51

    // Media / special (hardware keys)
    static let volumeUp          : CGKeyCode = 0x48
    static let volumeDown        : CGKeyCode = 0x49
    static let mute              : CGKeyCode = 0x4A
}

// MARK: - Default US-ANSI keycode → OverKeys label map

enum KeyMapping {

    /// Default mapping from macOS CGKeyCode to an OverKeys-compatible canonical label.
    static let defaultMap: [CGKeyCode: String] = [
        // Symbols / numbers row
        VK.ansi_Grave:         "`",
        VK.ansi_1:             "1",
        VK.ansi_2:             "2",
        VK.ansi_3:             "3",
        VK.ansi_4:             "4",
        VK.ansi_5:             "5",
        VK.ansi_6:             "6",
        VK.ansi_7:             "7",
        VK.ansi_8:             "8",
        VK.ansi_9:             "9",
        VK.ansi_0:             "0",
        VK.ansi_Minus:         "-",
        VK.ansi_Equal:         "=",
        // QWERTY row
        VK.ansi_Q:             "Q",
        VK.ansi_W:             "W",
        VK.ansi_E:             "E",
        VK.ansi_R:             "R",
        VK.ansi_T:             "T",
        VK.ansi_Y:             "Y",
        VK.ansi_U:             "U",
        VK.ansi_I:             "I",
        VK.ansi_O:             "O",
        VK.ansi_P:             "P",
        VK.ansi_LeftBracket:   "[",
        VK.ansi_RightBracket:  "]",
        VK.ansi_Backslash:     "\\",
        // Home row
        VK.ansi_A:             "A",
        VK.ansi_S:             "S",
        VK.ansi_D:             "D",
        VK.ansi_F:             "F",
        VK.ansi_G:             "G",
        VK.ansi_H:             "H",
        VK.ansi_J:             "J",
        VK.ansi_K:             "K",
        VK.ansi_L:             "L",
        VK.ansi_Semicolon:     ";",
        VK.ansi_Quote:         "'",
        // Bottom row
        VK.ansi_Z:             "Z",
        VK.ansi_X:             "X",
        VK.ansi_C:             "C",
        VK.ansi_V:             "V",
        VK.ansi_B:             "B",
        VK.ansi_N:             "N",
        VK.ansi_M:             "M",
        VK.ansi_Comma:         ",",
        VK.ansi_Period:        ".",
        VK.ansi_Slash:         "/",
        // Editing
        VK.tab:                "TAB",
        VK.return:             "ENTER",
        VK.space:              " ",
        VK.delete:             "BSPC",
        VK.forwardDelete:      "DEL",
        VK.escape:             "ESC",
        VK.help:               "INS",
        VK.capsLock:           "CAPS",
        // Modifiers
        VK.shift:              "LSFT",
        VK.rightShift:         "RSFT",
        VK.control:            "LCTRL",
        VK.rightControl:       "RCTRL",
        VK.option:             "LALT",
        VK.rightOption:        "RALT",
        VK.command:            "WIN",
        VK.rightCommand:       "WIN",
        VK.function_key:       "FN",
        // Navigation
        VK.home:               "HOME",
        VK.end:                "END",
        VK.pageUp:             "PGUP",
        VK.pageDown:           "PGDN",
        VK.leftArrow:          "←",
        VK.rightArrow:         "→",
        VK.downArrow:          "↓",
        VK.upArrow:            "↑",
        // Function keys
        VK.f1:                 "F1",
        VK.f2:                 "F2",
        VK.f3:                 "F3",
        VK.f4:                 "F4",
        VK.f5:                 "F5",
        VK.f6:                 "F6",
        VK.f7:                 "F7",
        VK.f8:                 "F8",
        VK.f9:                 "F9",
        VK.f10:                "F10",
        VK.f11:                "F11",
        VK.f12:                "F12",
        VK.f13:                "F13",
        VK.f14:                "F14",
        VK.f15:                "F15",
        VK.f16:                "F16",
        VK.f17:                "F17",
        VK.f18:                "F18",
        VK.f19:                "F19",
        VK.f20:                "F20",
        // Numpad
        VK.kp_0:               "NUM0",
        VK.kp_1:               "NUM1",
        VK.kp_2:               "NUM2",
        VK.kp_3:               "NUM3",
        VK.kp_4:               "NUM4",
        VK.kp_5:               "NUM5",
        VK.kp_6:               "NUM6",
        VK.kp_7:               "NUM7",
        VK.kp_8:               "NUM8",
        VK.kp_9:               "NUM9",
        VK.kp_Decimal:         "NUM.",
        VK.kp_Multiply:        "NUM*",
        VK.kp_Plus:            "NUM+",
        VK.kp_Clear:           "NUMLK",
        VK.kp_Divide:          "NUM/",
        VK.kp_Enter:           "NUMENTER",
        VK.kp_Minus:           "NUM-",
        VK.kp_Equals:          "NUM=",
        // Media
        VK.volumeUp:           "VOL+",
        VK.volumeDown:         "VOL-",
        VK.mute:               "MUTE",
    ]

    /// Lookup: CGKeyCode → canonical OverKeys key label.
    /// Falls back to hex string if no mapping found (e.g. international keys).
    static func label(for keyCode: CGKeyCode,
                      custom: [CGKeyCode: String] = [:]) -> String {
        if let override = custom[keyCode] { return override }
        return defaultMap[keyCode] ?? "0x\(String(keyCode, radix: 16, uppercase: true))"
    }

    /// Modifier-specific label from flagsChanged event keyCode.
    static func modifierLabel(for keyCode: CGKeyCode) -> String? {
        switch keyCode {
        case VK.shift:         return "LSFT"
        case VK.rightShift:    return "RSFT"
        case VK.control:       return "LCTRL"
        case VK.rightControl:  return "RCTRL"
        case VK.option:        return "LALT"
        case VK.rightOption:   return "RALT"
        case VK.command:       return "WIN"
        case VK.rightCommand:  return "WIN"
        case VK.capsLock:      return "CAPS"
        case VK.function_key:  return "FN"
        default:               return nil
        }
    }

    /// All canonical modifier key labels.
    static let modifierLabels: Set<String> = [
        "LSFT", "RSFT", "LCTRL", "RCTRL", "LALT", "RALT", "WIN", "CAPS", "FN"
    ]
}

// MARK: - Shift character table (US ANSI)

extension KeyMapping {
    /// Shifted versions of symbol keys for US ANSI layout.
    static let defaultShiftMap: [String: String] = [
        "`": "~",  "1": "!",  "2": "@",  "3": "#",  "4": "$",
        "5": "%",  "6": "^",  "7": "&",  "8": "*",  "9": "(",
        "0": ")",  "-": "_",  "=": "+",  "[": "{",  "]": "}",
        "\\": "|", ";": ":",  "'": "\"", ",": "<",  ".": ">",
        "/": "?"
    ]

    static func shiftedLabel(for label: String,
                             custom: [String: String] = [:]) -> String? {
        custom[label] ?? defaultShiftMap[label]
    }
}
