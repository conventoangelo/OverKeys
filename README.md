# OverKeys for macOS

A native macOS keyboard overlay that highlights keys in real time as you type. Built specifically for the **MoErgo Glove80** split ergonomic keyboard with full layer visualization, but also supports standard staggered, matrix, and split matrix layouts.

<!-- TODO: Add screenshot/gif of the overlay in action -->

## Features

- **Real-time key highlighting** -- see exactly which keys you press as you type
- **Glove80 layout** -- accurate column-staggered rendering with thumb clusters
- **Layer visualization** -- hold a thumb key to peek at Cursor, Symbol, or Mouse layers
- **Symbol layer badges** -- small corner labels show what each key does on the Symbol layer without activating it
- **Layer auto-inference** -- detects active layers from unique keycodes (e.g. arrow keys infer Cursor layer)
- **Customizable appearance** -- key size, colors, fonts, animations, opacity, and more
- **Click-through overlay** -- sits on top of all windows without intercepting clicks
- **All Spaces** -- overlay follows you across virtual desktops
- **Menu bar app** -- no Dock icon, lives quietly in the menu bar
- **JSON config** -- compatible with the original OverKeys config format for custom layouts

## Installation

### From DMG (recommended)

1. Download the latest `.dmg` from [Releases](../../releases)
2. Open the DMG and drag **OverKeys** to your Applications folder
3. Launch OverKeys
4. **Grant Accessibility permission** (required -- see below)

### Grant Accessibility Permission

OverKeys uses macOS Accessibility APIs to detect global key presses. Without this permission, the overlay cannot react to your typing.

1. On first launch, macOS will prompt you to grant Accessibility access
2. If the prompt doesn't appear, go to **System Settings > Privacy & Security > Accessibility**
3. Click the **+** button and add OverKeys (or toggle it on if already listed)
4. **Restart OverKeys** after granting permission

> **Note:** If you rebuild or update the app binary, macOS may revoke the permission. You'll need to toggle it off and back on in System Settings, then restart the app.

### Build from Source

**Requirements:**
- macOS 13.0+
- Xcode 14+ with Command Line Tools
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

```bash
# Clone the repo
git clone https://github.com/conventoangelo/OverKeys.git
cd OverKeys

# Generate the Xcode project
cd OverKeysMac
xcodegen generate --spec project.yml

# Build (universal binary)
xcodebuild -project OverKeysMac.xcodeproj \
  -scheme OverKeysMac \
  -configuration Release \
  -archivePath ../build/OverKeysMac.xcarchive \
  archive \
  ONLY_ACTIVE_ARCH=NO

# Or use the dev deploy script (builds, installs to ~/Applications, launches)
cd ..
bash scripts/deploy.sh
```

## Configuration

OverKeys reads its configuration from:

```
~/Library/Application Support/OverKeysMac/config.json
```

On first launch, a default config is seeded. You can edit it to define custom layouts, layer triggers, key aliases, ignored keys, and shift mappings. The format is compatible with the original [OverKeys](https://github.com/conventoangelo/OverKeys) config schema.

Access the config file from the app: **Settings > Advanced > Open Config File**.

## Glove80 / TailorKey Setup

If you use a Glove80 with TailorKey firmware:

1. Set **Keymap Style** to "Glove80" in Settings > Keyboard
2. Define your layers in `config.json` with trigger keys matching your firmware (F16, F17, F19, =)
3. The overlay will automatically show layer diffs when you hold thumb keys

Supported layers: TK Cursor (BSPC), TK Symbol (SPC), TK Mouse (ENTER), TK Lower (=).

## Scripts

| Script | Purpose |
|---|---|
| `scripts/deploy.sh` | Dev workflow: build, install to ~/Applications, test, launch |
| `scripts/install_dev.sh` | Full test suite: startup, event tap, key reaction, layer triggers |
| `scripts/package_dmg.sh` | Release: build, sign, notarize, create DMG |

## License

[GPL-3.0](LICENSE)
