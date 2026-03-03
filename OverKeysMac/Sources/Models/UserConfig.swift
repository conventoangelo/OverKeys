// UserConfig.swift
// Full user configuration model — mirrors OverKeys' config.json format.

import Foundation

struct UserConfig: Codable, Equatable {
    // MARK: Layout
    var defaultUserLayout: String?      // name of active layout
    var altLayout: String?              // secondary layout for alt-character display
    var userLayouts: [KeyboardLayout]   // custom user-defined layouts

    // MARK: Typography
    var customFont: String?             // font family name

    // MARK: Key behaviour
    var customShiftMappings: [String: String]  // key → shifted character override
    var customAliases: [String: [String]]      // label → combo (e.g. "UNDO" → ["Control","Z"])
    var customKeys: [String: String]           // raw keycode overrides
    var ignoredKeys: [String]                 // key names to suppress in highlight

    // MARK: Kanata integration
    var kanataHost: String?
    var kanataPort: Int?

    init(
        defaultUserLayout: String? = nil,
        altLayout: String? = nil,
        userLayouts: [KeyboardLayout] = [],
        customFont: String? = nil,
        customShiftMappings: [String: String] = [:],
        customAliases: [String: [String]] = [:],
        customKeys: [String: String] = [:],
        ignoredKeys: [String] = [],
        kanataHost: String? = nil,
        kanataPort: Int? = nil
    ) {
        self.defaultUserLayout = defaultUserLayout
        self.altLayout = altLayout
        self.userLayouts = userLayouts
        self.customFont = customFont
        self.customShiftMappings = customShiftMappings
        self.customAliases = customAliases
        self.customKeys = customKeys
        self.ignoredKeys = ignoredKeys
        self.kanataHost = kanataHost
        self.kanataPort = kanataPort
    }

    // MARK: Codable — graceful decoding with defaults

    enum CodingKeys: String, CodingKey {
        case defaultUserLayout, altLayout, userLayouts
        case customFont, customShiftMappings, customAliases, customKeys
        case ignoredKeys, kanataHost, kanataPort
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        defaultUserLayout  = try c.decodeIfPresent(String.self,            forKey: .defaultUserLayout)
        altLayout          = try c.decodeIfPresent(String.self,            forKey: .altLayout)
        userLayouts        = try c.decodeIfPresent([KeyboardLayout].self,  forKey: .userLayouts)   ?? []
        customFont         = try c.decodeIfPresent(String.self,            forKey: .customFont)
        customShiftMappings = try c.decodeIfPresent([String: String].self, forKey: .customShiftMappings) ?? [:]
        customAliases      = try c.decodeIfPresent([String: [String]].self, forKey: .customAliases)     ?? [:]
        customKeys         = try c.decodeIfPresent([String: String].self,  forKey: .customKeys)         ?? [:]
        ignoredKeys        = try c.decodeIfPresent([String].self,          forKey: .ignoredKeys)        ?? []
        kanataHost         = try c.decodeIfPresent(String.self,            forKey: .kanataHost)
        kanataPort         = try c.decodeIfPresent(Int.self,               forKey: .kanataPort)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(defaultUserLayout,   forKey: .defaultUserLayout)
        try c.encodeIfPresent(altLayout,           forKey: .altLayout)
        if !userLayouts.isEmpty        { try c.encode(userLayouts,         forKey: .userLayouts) }
        try c.encodeIfPresent(customFont,          forKey: .customFont)
        if !customShiftMappings.isEmpty { try c.encode(customShiftMappings, forKey: .customShiftMappings) }
        if !customAliases.isEmpty       { try c.encode(customAliases,       forKey: .customAliases) }
        if !customKeys.isEmpty          { try c.encode(customKeys,          forKey: .customKeys) }
        if !ignoredKeys.isEmpty         { try c.encode(ignoredKeys,         forKey: .ignoredKeys) }
        try c.encodeIfPresent(kanataHost, forKey: .kanataHost)
        try c.encodeIfPresent(kanataPort, forKey: .kanataPort)
    }

    // MARK: Helpers

    /// All layouts accessible to the user: user-defined first, then built-ins.
    var allLayouts: [KeyboardLayout] {
        userLayouts + KeyboardLayout.all
    }

    func resolveLayout(named name: String?) -> KeyboardLayout {
        guard let name else { return .qwerty }
        return KeyboardLayout.find(named: name, in: userLayouts) ?? .qwerty
    }
}
