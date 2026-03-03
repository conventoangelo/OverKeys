#!/usr/bin/env bash
# package_dmg.sh — Build, sign, notarize, and package OverKeysMac as a DMG.
# Usage: ./scripts/package_dmg.sh [--skip-notarize] [--team-id TEAM_ID] [--profile KEYCHAIN_PROFILE]
#
# Prerequisites:
#   - Xcode 15+ with command-line tools
#   - Developer ID Application certificate in your keychain
#   - Keychain profile stored via:
#       xcrun notarytool store-credentials "overkeys-notarize" \
#         --apple-id "you@example.com" \
#         --team-id "XXXXXXXXXX" \
#         --password "@keychain:AC_PASSWORD"
#   - create-dmg: brew install create-dmg   (optional; falls back to hdiutil)

set -euo pipefail

# ──────────────── Configuration ────────────────

APP_NAME="OverKeys"
BUNDLE_ID="com.overkeys.mac"
XCODEPROJ="OverKeysMac/OverKeysMac.xcodeproj"
SCHEME="OverKeysMac"
CONFIGURATION="Release"

DERIVED_DATA="$(pwd)/build/DerivedData"
ARCHIVE_PATH="$(pwd)/build/${APP_NAME}.xcarchive"
EXPORT_PATH="$(pwd)/build/Export"
DMG_STAGING="$(pwd)/build/DMGStaging"
ARTIFACTS="$(pwd)/build/Artifacts"

# Override via CLI args
SKIP_NOTARIZE=false
TEAM_ID="${TEAM_ID:-}"          # or pass --team-id XXXXXXXXXX
KEYCHAIN_PROFILE="${NOTARIZE_PROFILE:-overkeys-notarize}"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:-Developer ID Application}"

# ──────────────── Parse args ────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-notarize)  SKIP_NOTARIZE=true ;;
    --team-id)        TEAM_ID="$2"; shift ;;
    --profile)        KEYCHAIN_PROFILE="$2"; shift ;;
    --identity)       CODESIGN_IDENTITY="$2"; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
  shift
done

# ──────────────── 0. Sanity checks ────────────────

if [[ -z "${TEAM_ID}" ]]; then
  echo "⚠️  TEAM_ID not set. Signing will use automatic selection."
  echo "   Set it: export TEAM_ID=XXXXXXXXXX  or pass --team-id XXXXXXXXXX"
fi

command -v xcrun >/dev/null 2>&1 || { echo "❌ Xcode command-line tools not found"; exit 1; }

mkdir -p "$ARTIFACTS"

# ──────────────── 1. Generate Xcode project (if using XcodeGen) ────────────────

if command -v xcodegen >/dev/null 2>&1 && [[ -f "OverKeysMac/project.yml" ]]; then
  echo "🔧 Generating Xcode project via XcodeGen…"
  pushd OverKeysMac > /dev/null
  xcodegen generate --spec project.yml
  popd > /dev/null
else
  echo "ℹ️  Skipping XcodeGen (not installed or project.yml not in OverKeysMac/)"
fi

# ──────────────── 2. Build archive ────────────────

echo "📦 Archiving ${SCHEME} (${CONFIGURATION})…"

TEAM_ARGS=()
[[ -n "${TEAM_ID}" ]] && TEAM_ARGS=(DEVELOPMENT_TEAM="${TEAM_ID}")

xcodebuild archive \
  -project "${XCODEPROJ}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -archivePath "${ARCHIVE_PATH}" \
  -derivedDataPath "${DERIVED_DATA}" \
  "${TEAM_ARGS[@]}" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  | xcpretty 2>/dev/null || cat

echo "✅ Archive: ${ARCHIVE_PATH}"

# ──────────────── 3. Export .app ────────────────

cat > /tmp/ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>automatic</string>
    $([ -n "${TEAM_ID}" ] && echo "<key>teamID</key><string>${TEAM_ID}</string>")
    <key>hardcodedDeveloperId</key>
    <false/>
</dict>
</plist>
EOF

rm -rf "${EXPORT_PATH}"
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist /tmp/ExportOptions.plist

APP_PATH="${EXPORT_PATH}/${APP_NAME}.app"
echo "✅ Exported: ${APP_PATH}"

# ──────────────── 4. Verify codesign ────────────────

echo "🔍 Verifying code signature…"
codesign --verify --deep --strict --verbose=2 "${APP_PATH}"
spctl --assess --type exec --verbose "${APP_PATH}" || echo "⚠️  Gatekeeper assess failed (expected before notarization)"

# ──────────────── 5. Create DMG ────────────────

VERSION=$(defaults read "${APP_PATH}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="${ARTIFACTS}/${DMG_NAME}"

echo "💿 Creating DMG: ${DMG_NAME}…"

if command -v create-dmg >/dev/null 2>&1; then
  # Prettier DMG with create-dmg
  create-dmg \
    --volname "${APP_NAME}" \
    --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 128 \
    --icon "${APP_NAME}.app" 150 180 \
    --hide-extension "${APP_NAME}.app" \
    --app-drop-link 450 180 \
    --no-internet-enable \
    "${DMG_PATH}" \
    "${EXPORT_PATH}"
else
  # Fallback: plain hdiutil DMG
  rm -rf "${DMG_STAGING}"
  mkdir -p "${DMG_STAGING}"
  cp -R "${APP_PATH}" "${DMG_STAGING}/"
  ln -s /Applications "${DMG_STAGING}/Applications"

  hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${DMG_STAGING}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

  rm -rf "${DMG_STAGING}"
fi

echo "✅ DMG: ${DMG_PATH}"

# ──────────────── 6. Sign the DMG ────────────────

echo "🔏 Signing DMG…"
codesign --force --sign "${CODESIGN_IDENTITY}" "${DMG_PATH}"

# ──────────────── 7. Notarize (optional) ────────────────

if [[ "${SKIP_NOTARIZE}" == "true" ]]; then
  echo "⏭️  Skipping notarization (--skip-notarize)"
else
  echo "📬 Submitting for notarization (profile: ${KEYCHAIN_PROFILE})…"
  xcrun notarytool submit "${DMG_PATH}" \
    --keychain-profile "${KEYCHAIN_PROFILE}" \
    --wait

  echo "📎 Stapling notarization ticket to DMG…"
  xcrun stapler staple "${DMG_PATH}"

  echo "📎 Stapling to .app as well…"
  xcrun stapler staple "${APP_PATH}"

  echo "🔍 Final Gatekeeper check…"
  spctl --assess --type open --context context:primary-signature "${DMG_PATH}"
fi

# ──────────────── Done ────────────────

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  ✅  ${APP_NAME} v${VERSION} packaged successfully       ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  DMG: ${DMG_PATH}"
echo "╚══════════════════════════════════════════════════╝"
