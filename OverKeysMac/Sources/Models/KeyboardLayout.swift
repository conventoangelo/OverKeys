// KeyboardLayout.swift
// Data models for keyboard layouts, layers, and key geometry.

import Foundation

// MARK: - Layer trigger type

enum LayerTriggerType: String, Codable {
    case held
    case toggle
}

// MARK: - KeyboardLayout

/// A single keyboard layer / layout definition.
/// `keys` is a 2-D array: outer = rows, inner = key labels (OverKeys format).
struct KeyboardLayout: Codable, Identifiable, Equatable {
    var id: String { name }
    let name: String
    let keys: [[String]]
    let trigger: String?      // e.g. "F14" — key that activates this layer
    let type: LayerTriggerType? // held | toggle
    let foreign: Bool          // true for non-Latin scripts

    init(name: String,
         keys: [[String]],
         trigger: String? = nil,
         type: LayerTriggerType? = nil,
         foreign: Bool = false) {
        self.name = name
        self.keys = keys
        self.trigger = trigger
        self.type = type
        self.foreign = foreign
    }

    // Custom decoder so JSON without a "foreign" key still decodes correctly.
    // The synthesised decoder would throw DecodingError.keyNotFound for the
    // non-optional Bool, silently causing the entire userLayouts array to be
    // replaced with [] and breaking all layer triggers.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name    = try c.decode(String.self,           forKey: .name)
        keys    = try c.decode([[String]].self,        forKey: .keys)
        trigger = try c.decodeIfPresent(String.self,  forKey: .trigger)
        type    = try c.decodeIfPresent(LayerTriggerType.self, forKey: .type)
        foreign = try c.decodeIfPresent(Bool.self,    forKey: .foreign) ?? false
    }

    static func == (lhs: KeyboardLayout, rhs: KeyboardLayout) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Built-in layouts (mirrors OverKeys' availableLayouts list)

extension KeyboardLayout {
    static let qwerty = KeyboardLayout(
        name: "QWERTY",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
            ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\"],
            ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "ENTER"],
            ["LSFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    static let colemak = KeyboardLayout(
        name: "Colemak",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
            ["TAB", "Q", "W", "F", "P", "G", "J", "L", "U", "Y", ";", "[", "]", "\\"],
            ["CAPS", "A", "R", "S", "T", "D", "H", "N", "E", "I", "O", "'", "ENTER"],
            ["LSFT", "Z", "X", "C", "V", "B", "K", "M", ",", ".", "/", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    static let dvorak = KeyboardLayout(
        name: "Dvorak",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "[", "]", "BSPC"],
            ["TAB", "'", ",", ".", "P", "Y", "F", "G", "C", "R", "L", "/", "=", "\\"],
            ["CAPS", "A", "O", "E", "U", "I", "D", "H", "T", "N", "S", "-", "ENTER"],
            ["LSFT", ";", "Q", "J", "K", "X", "B", "M", "W", "V", "Z", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    static let colemakDH = KeyboardLayout(
        name: "Colemak-DH",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
            ["TAB", "Q", "W", "F", "P", "B", "J", "L", "U", "Y", ";", "[", "]", "\\"],
            ["CAPS", "A", "R", "S", "T", "G", "M", "N", "E", "I", "O", "'", "ENTER"],
            ["LSFT", "X", "C", "D", "V", "Z", "K", "H", ",", ".", "/", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    static let canary = KeyboardLayout(
        name: "Canary",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
            ["TAB", "W", "L", "Y", "P", "K", "Z", "X", "O", "U", ";", "[", "]", "\\"],
            ["CAPS", "C", "R", "S", "T", "B", "F", "N", "E", "I", "A", "'", "ENTER"],
            ["LSFT", "J", "V", "D", "G", "Q", "M", "H", "/", ",", ".", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    static let workman = KeyboardLayout(
        name: "Workman",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
            ["TAB", "Q", "D", "R", "W", "B", "J", "F", "U", "P", ";", "[", "]", "\\"],
            ["CAPS", "A", "S", "H", "T", "G", "Y", "N", "E", "O", "I", "'", "ENTER"],
            ["LSFT", "Z", "X", "M", "C", "V", "K", "L", ",", ".", "/", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    static let graphite = KeyboardLayout(
        name: "Graphite",
        keys: [
            ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
            ["TAB", "B", "L", "D", "W", "Z", "'", "F", "O", "U", "J", ";", "[", "\\"],
            ["CAPS", "N", "R", "T", "S", "G", "Y", "H", "A", "E", "I", ",", "ENTER"],
            ["LSFT", "Q", "X", "M", "C", "V", "K", "P", ".", "/", "=", "RSFT"],
            ["LCTRL", "WIN", "LALT", " ", "RALT", "FN", "RCTRL"]
        ]
    )

    // MARK: - Glove80 (MoErgo split columnar, TailorKey layout)
    //
    // Row layout (left 6 cols + right 6 cols = 12 per main row):
    //   Rows 0-3 : main alpha + number rows  (12 keys, 6 per half)
    //   Row  4   : bottom modifier row       (10 keys, 5 per half)
    //   Row  5   : thumb cluster upper       ( 6 keys, 3 per half)
    //   Row  6   : thumb cluster lower       ( 6 keys, 3 per half)
    static let glove80 = KeyboardLayout(
        name: "Glove80",
        keys: [
            // Row 0 — number row (TailorKey: = on pinky, not `)
            ["=",    "1",    "2",    "3",    "4",    "5",
             "6",    "7",    "8",    "9",    "0",    "-"],
            // Row 1 — top alpha
            ["TAB",  "Q",    "W",    "E",    "R",    "T",
             "Y",    "U",    "I",    "O",    "P",    "\\"],
            // Row 2 — home row (TailorKey: ESC on pinky, not CAPS)
            ["ESC",  "A",    "S",    "D",    "F",    "G",
             "H",    "J",    "K",    "L",    ";",    "'"],
            // Row 3 — bottom alpha (TailorKey: ` on pinky, PGUP on outer right)
            ["`",    "Z",    "X",    "C",    "V",    "B",
             "N",    "M",    ",",    ".",    "/",    "PGUP"],
            // Row 4 — bottom extension (5L + 5R): arrows + brackets
            ["Magic","HOME", "END",  "←",    "→",
             "↑",    "↓",    "[",    "]",    "PGDN"],
            // Row 5 — inner thumb (3L + 3R): CapsWord, Ctrl, Lower | GUI, Ctrl, CapsWord
            ["CapsW","LCTRL","LOWER","WIN",  "RCTRL","CapsW"],
            // Row 6 — outer thumb (3L + 3R): BSPC(Cursor), DEL, Alt | Alt, ENTER(Mouse), SPC(Symbol)
            ["BSPC", "DEL",  "LALT", "RALT", "ENTER","SPC"]
        ]
    )

    static let all: [KeyboardLayout] = [
        .qwerty, .colemak, .colemakDH, .dvorak, .canary, .workman, .graphite, .glove80
    ]

    static func find(named name: String, in extra: [KeyboardLayout] = []) -> KeyboardLayout? {
        let pool = extra + all
        return pool.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }
}

// MARK: - Key width helpers (standard ANSI sizing)

extension KeyboardLayout {
    /// Returns the display width of a key in base-unit multiples.
    static func widthMultiplier(for label: String) -> CGFloat {
        switch label.uppercased() {
        case "BSPC", "BACKSPACE":        return 2.00
        case "TAB":                       return 1.50
        case "CAPS", "CAPSLOCK":          return 1.75
        case "ENTER", "RETURN":           return 2.25
        case "LSFT", "SHIFT":             return 2.25
        case "RSFT":                      return 2.75
        case "LCTRL", "RCTRL", "CTRL":    return 1.25
        case "LALT", "RALT", "ALT":       return 1.25
        case "WIN", "CMD", "META":        return 1.25
        case "FN":                        return 1.25
        case "\\":                        return 1.50
        case " ", "SPC", "SPACE":         return 6.25
        default:                          return 1.00
        }
    }

    /// Row stagger offset (in base-unit multiples) for staggered layouts.
    static func staggerOffset(forRow row: Int) -> CGFloat {
        switch row {
        case 1: return 0.50
        case 2: return 0.75
        case 3: return 1.25
        default: return 0.00
        }
    }

    // MARK: - Glove80 column stagger (points, positive = lower on screen)
    //
    // Finger assignment for each half (column index 0 = outer, 5 = inner):
    //   Left  col 0 = extra/outer  col 3 = middle (highest)  col 5 = inner-index
    //   Right col 0 = inner-index  col 2 = middle (highest)  col 5 = extra/outer
    static let glove80LeftStagger:  [CGFloat] = [10,  5,  0, -16, -8,  2]
    static let glove80RightStagger: [CGFloat] = [ 2, -8, -16,  0,  5, 10]

    // Number of main rows that use column stagger (rows 0-3)
    static let glove80MainRowCount = 4
    // Number of modifier rows rendered flat after the staggered body (row 4)
    static let glove80ModRowCount  = 1
}
