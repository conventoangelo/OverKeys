# OverKeysMac — Release Guide

Complete steps to build, sign, notarize, and distribute a DMG.

---

## Prerequisites

| Tool | Install |
|------|---------|
| Xcode 15+ | Mac App Store or developer.apple.com |
| Xcode CLI tools | `xcode-select --install` |
| XcodeGen | `brew install xcodegen` |
| create-dmg (optional, nicer DMGs) | `brew install create-dmg` |
| xcpretty (optional, cleaner output) | `gem install xcpretty` |
| Apple Developer ID certificate | [developer.apple.com/account](https://developer.apple.com/account) — "Certificates, IDs & Profiles" |

**Certificate needed:** "Developer ID Application: Your Name (TEAM_ID)"

---

## One-time keychain profile setup (for notarytool)

Store your Apple ID credentials once so you never pass passwords in scripts:

```bash
xcrun notarytool store-credentials "overkeys-notarize" \
  --apple-id "you@example.com" \
  --team-id "XXXXXXXXXX" \
  --password "@keychain:APP_SPECIFIC_PASSWORD"
```

Generate an **App-Specific Password** at [appleid.apple.com](https://appleid.apple.com) → Security → App-Specific Passwords.

Verify it works:
```bash
xcrun notarytool history --keychain-profile "overkeys-notarize"
```

---

## Step 1: Generate Xcode project

XcodeGen reads `OverKeysMac/project.yml` and writes the `.xcodeproj`:

```bash
cd OverKeysMac
xcodegen generate --spec project.yml
cd ..
```

Re-run this whenever you add/remove source files.

---

## Step 2: Build, package, and notarize (full pipeline)

```bash
export TEAM_ID="XXXXXXXXXX"
./scripts/package_dmg.sh --team-id "${TEAM_ID}" --profile overkeys-notarize
```

This runs:
1. `xcodegen generate`
2. `xcodebuild archive` → universal binary (arm64 + x86_64)
3. `xcodebuild -exportArchive` with Developer ID method
4. `create-dmg` (or `hdiutil` fallback)
5. `codesign` the DMG
6. `xcrun notarytool submit … --wait`
7. `xcrun stapler staple`
8. Final `spctl` Gatekeeper check

**Output:** `build/Artifacts/OverKeys-<version>.dmg`

---

## Step 3: Manual steps (if script fails)

### Archive only

```bash
xcodebuild archive \
  -project OverKeysMac/OverKeysMac.xcodeproj \
  -scheme OverKeysMac \
  -configuration Release \
  -archivePath build/OverKeys.xcarchive \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  DEVELOPMENT_TEAM="XXXXXXXXXX"
```

### Export .app

```bash
xcodebuild -exportArchive \
  -archivePath build/OverKeys.xcarchive \
  -exportPath build/Export \
  -exportOptionsPlist scripts/ExportOptions.plist
```

`scripts/ExportOptions.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>method</key><string>developer-id</string>
    <key>teamID</key><string>XXXXXXXXXX</string>
</dict>
</plist>
```

### Verify signature

```bash
codesign --verify --deep --strict --verbose=2 build/Export/OverKeys.app
codesign -dv --verbose=4 build/Export/OverKeys.app
```

### Create DMG manually

```bash
mkdir -p /tmp/OverKeysDMG
cp -R build/Export/OverKeys.app /tmp/OverKeysDMG/
ln -s /Applications /tmp/OverKeysDMG/Applications

hdiutil create \
  -volname "OverKeys" \
  -srcfolder /tmp/OverKeysDMG \
  -ov -format UDZO \
  build/Artifacts/OverKeys-1.0.0.dmg

codesign --force --sign "Developer ID Application: …" build/Artifacts/OverKeys-1.0.0.dmg
```

### Notarize

```bash
xcrun notarytool submit build/Artifacts/OverKeys-1.0.0.dmg \
  --keychain-profile "overkeys-notarize" \
  --wait
```

If it fails, fetch the log:
```bash
xcrun notarytool log <SUBMISSION_ID> \
  --keychain-profile "overkeys-notarize" notarize.log
cat notarize.log
```

### Staple

```bash
xcrun stapler staple build/Artifacts/OverKeys-1.0.0.dmg
xcrun stapler staple build/Export/OverKeys.app
```

### Final verification

```bash
spctl --assess --type open --context context:primary-signature build/Artifacts/OverKeys-1.0.0.dmg
```

---

## Entitlements reference

OverKeysMac is **not sandboxed** because:
- `CGEventTapCreate` at session level requires Accessibility permission
- Sandbox prevents creating session-level event taps
- Distribution must be via **Developer ID** (direct download), NOT the Mac App Store

The hardened runtime is still enabled (`ENABLE_HARDENED_RUNTIME = YES`) for notarization.

---

## Common errors

| Error | Cause | Fix |
|-------|-------|-----|
| `CGEventTapCreate returns nil` | Missing Accessibility permission | User must grant in System Settings → Privacy & Security → Accessibility |
| `notarytool: Error 1` | Wrong Apple ID / app-specific password | Re-run `store-credentials` |
| `The executable does not have the hardened runtime enabled` | Missing entitlement flag | Set `ENABLE_HARDENED_RUNTIME=YES` in build settings |
| `[NSURL ...] is not permitted` | Sandbox blocking file access | Ensure `ENABLE_APP_SANDBOX=NO` |
| `spctl: rejected` on pre-notarize check | Expected — not notarized yet | Run notarize step, then re-check |
| DMG stuck at "Verifying…" | Gatekeeper quarantine not cleared | Staple was skipped; re-run `xcrun stapler staple` |
| Archive is i386-only | Wrong ARCHS setting | Set `ARCHS="arm64 x86_64"` and `ONLY_ACTIVE_ARCH=NO` |

---

## Versioning

Version is read from `Info.plist`:
- `CFBundleShortVersionString` → marketing version (e.g. `1.2.0`)
- `CFBundleVersion` → build number (increment each release)

Update before releasing:
```bash
# Example: bump to 1.1.0 build 5
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.1.0" OverKeysMac/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 5"               OverKeysMac/Info.plist
```

---

## GitHub Release checklist

- [ ] Update `CFBundleShortVersionString` and `CFBundleVersion`
- [ ] Update `CHANGELOG.md`
- [ ] Tag: `git tag -s v1.1.0 -m "Release v1.1.0"`
- [ ] Run `./scripts/package_dmg.sh`
- [ ] Verify DMG opens correctly
- [ ] Upload `OverKeys-1.1.0.dmg` to GitHub Releases
- [ ] Push tag: `git push origin v1.1.0`
