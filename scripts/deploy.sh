#!/bin/bash
# deploy.sh — Build, install to ~/Applications, verify event capture, and launch.
# Single install location: ~/Applications/OverKeysMac.app
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../OverKeysMac" && pwd)"
DERIVED_APP="$HOME/Library/Developer/Xcode/DerivedData/OverKeysMac-gpcmteeknmxpuhgjwzxtswubqhcm/Build/Products/Debug/OverKeysMac.app"
INSTALL_DIR="$HOME/Applications"
INSTALL_APP="$INSTALL_DIR/OverKeysMac.app"
LOG="/tmp/overkeys_deploy_test.log"

echo "=== OverKeysMac Deploy ==="

# 1. Build
echo "[1/5] Building..."
cd "$PROJECT_DIR"
if ! xcodebuild -project OverKeysMac.xcodeproj -scheme OverKeysMac \
     -destination 'platform=macOS' build 2>&1 | tail -3 | grep -q "BUILD SUCCEEDED"; then
    echo "FAIL: Build failed"
    exit 1
fi
echo "      Build succeeded"

# 2. Kill existing
echo "[2/5] Stopping existing instance..."
pkill -9 -x OverKeysMac 2>/dev/null || true
sleep 1

# 3. Install to ~/Applications (replace old copy with fresh build)
echo "[3/5] Installing to $INSTALL_APP ..."
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_APP"
cp -R "$DERIVED_APP" "$INSTALL_APP"
echo "      Installed"

# 4. Launch from ~/Applications and test event capture
echo "[4/5] Testing event capture..."
"$INSTALL_APP/Contents/MacOS/OverKeysMac" 2>"$LOG" &
APP_PID=$!
sleep 2

# Send a synthetic keystroke
osascript -e 'tell application "System Events" to key code 0' 2>/dev/null || true
sleep 1

if grep -q "keyDown" "$LOG"; then
    echo "      Event capture OK"
    kill "$APP_PID" 2>/dev/null; wait "$APP_PID" 2>/dev/null || true
else
    echo "FAIL: No key events captured!"
    echo "      The binary signature changed — Accessibility permission needs re-granting."
    echo "      → Go to System Settings → Privacy & Security → Accessibility"
    echo "      → Remove OverKeysMac if listed, then add: $INSTALL_APP"
    echo "      → Then run this script again"
    kill "$APP_PID" 2>/dev/null; wait "$APP_PID" 2>/dev/null || true
    exit 1
fi

# 5. Launch properly
echo "[5/5] Launching..."
open "$INSTALL_APP"
sleep 1

# Quick verify the launched instance
PID=$(pgrep -x OverKeysMac || true)
if [ -n "$PID" ]; then
    echo ""
    echo "=== SUCCESS ==="
    echo "OverKeysMac running (PID $PID)"
    echo "Installed at: $INSTALL_APP"
else
    echo "FAIL: App did not start"
    exit 1
fi
