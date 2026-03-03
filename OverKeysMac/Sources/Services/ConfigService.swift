// ConfigService.swift
// Loads and saves config.json from ~/Library/Application Support/OverKeysMac/

import Foundation
import AppKit

final class ConfigService {

    // MARK: Paths

    private static let appSupportDir: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir  = base.appendingPathComponent("OverKeysMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    static let configURL = appSupportDir.appendingPathComponent("config.json")
    static let logDir    = FileManager.default
        .urls(for: .libraryDirectory, in: .userDomainMask).first!
        .appendingPathComponent("Logs/OverKeysMac", isDirectory: true)

    // MARK: Load

    static func load() -> UserConfig {
        // First run: seed with bundled default_config.json
        if !FileManager.default.fileExists(atPath: configURL.path) {
            seedDefaultConfig()
        }
        guard
            let data   = try? Data(contentsOf: configURL),
            let config = try? JSONDecoder().decode(UserConfig.self, from: data)
        else { return UserConfig() }
        return config
    }

    // MARK: Save

    static func save(_ config: UserConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: configURL, options: .atomicWrite)
    }

    // MARK: Open in default editor

    static func openInEditor() {
        NSWorkspace.shared.open(configURL)
    }

    static func revealInFinder() {
        NSWorkspace.shared.selectFile(configURL.path, inFileViewerRootedAtPath: "")
    }

    // MARK: Private — seed bundled default

    private static func seedDefaultConfig() {
        // Try top-level resource first; fall back to "Resources/" subdirectory
        // (occurs when project.yml uses `type: folder` for the Resources dir).
        let bundleURL = Bundle.main.url(forResource: "default_config", withExtension: "json")
            ?? Bundle.main.url(forResource: "default_config", withExtension: "json",
                               subdirectory: "Resources")
        guard let bundleURL, let data = try? Data(contentsOf: bundleURL) else {
            fputs("[Config] ERROR: default_config.json not found in bundle\n", stderr)
            return
        }
        fputs("[Config] seeding config from \(bundleURL.path)\n", stderr)
        try? data.write(to: configURL, options: .atomicWrite)
    }
}
