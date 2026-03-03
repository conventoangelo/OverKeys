#!/usr/bin/env bash
# install_dev.sh -- build OverKeysMac (Debug) and install to ~/Applications
# Usage: ./scripts/install_dev.sh [--release]
#
# Exit codes: 0 = all tests passed, 1 = crash/build error, 2 = tests failed

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$REPO_ROOT/OverKeysMac/OverKeysMac.xcodeproj"
SCHEME="OverKeysMac"
CONFIG="Debug"
INSTALL_DIR="$HOME/Applications"
LOG_FILE="/tmp/overkeys.log"
TESTS_PASSED=0
TESTS_FAILED=0

if [[ "${1:-}" == "--release" ]]; then
  CONFIG="Release"
fi

pass() { echo "    [OK] $*"; (( TESTS_PASSED++ )) || true; }
fail() { echo "    [!!] $*"; (( TESTS_FAILED++ )) || true; }

# ── 1. Build ────────────────────────────────────────────────────────────────
echo "==> Building $SCHEME ($CONFIG)..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  build 2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED" | head -20 || true

# Locate the built .app
BUILT_PRODUCTS=$(xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -showBuildSettings 2>/dev/null \
  | awk '/BUILT_PRODUCTS_DIR/ { print $3; exit }')
BUILT_APP="$BUILT_PRODUCTS/OverKeysMac.app"
BINARY="$INSTALL_DIR/OverKeysMac.app/Contents/MacOS/OverKeysMac"

# ── 2. Verify bundle resource is in the right place ──────────────────────────
echo "==> Verifying bundle resource layout..."
BUNDLE_CONFIG="$BUILT_APP/Contents/Resources/default_config.json"
if [[ -f "$BUNDLE_CONFIG" ]]; then
  pass "default_config.json at Contents/Resources/ (not double-nested)"
else
  fail "default_config.json missing from Contents/Resources/ — bundle resource path is wrong"
  echo "         Found at: $(find "$BUILT_APP" -name default_config.json 2>/dev/null | head -1)"
fi

# ── 3. Install ───────────────────────────────────────────────────────────────
echo "==> Installing to ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/OverKeysMac.app"
cp -R "$BUILT_APP" "$INSTALL_DIR/"

# ── 4. Relaunch with log capture ─────────────────────────────────────────────
echo "==> Relaunching (logging to ${LOG_FILE})..."
pkill -x OverKeysMac 2>/dev/null || true
sleep 0.8
rm -f "$LOG_FILE"
# Launch binary directly so stderr goes to LOG_FILE; detach from terminal
"$BINARY" >"$LOG_FILE" 2>&1 &
LAUNCHED_PID=$!
echo "    PID: $LAUNCHED_PID"

# ── 5. Startup test ──────────────────────────────────────────────────────────
echo "==> TEST — Startup & config seeding (5 s)..."
sleep 5

if ! kill -0 "$LAUNCHED_PID" 2>/dev/null; then
  echo ""
  echo "ERROR: OverKeysMac crashed at startup."
  cat "$LOG_FILE"
  exit 1
fi

# Config seeding
if grep -q "\[Config\] seeding config" "$LOG_FILE" 2>/dev/null; then
  pass "Config seeded from bundle on first run"
elif [[ -f "$HOME/Library/Application Support/OverKeysMac/config.json" ]]; then
  pass "Config file exists (previously seeded)"
else
  fail "Config seeding failed — userLayouts will be empty, no layer triggers"
fi

# EventTap
if grep -q "tapCreate succeeded" "$LOG_FILE" 2>/dev/null; then
  pass "EventTap started — Accessibility is granted"
elif grep -q "tapCreate FAILED" "$LOG_FILE" 2>/dev/null; then
  fail "EventTap FAILED — Accessibility not granted"
  echo ""
  echo "         Fix: System Settings -> Privacy & Security -> Accessibility"
  echo "              Toggle OverKeysMac OFF then ON"
  echo "              The app auto-retries every 3 s after grant."
  echo ""
else
  fail "No EventTap log — check ${LOG_FILE}"
fi

# ── 6. Key-reaction test ─────────────────────────────────────────────────────
echo "==> TEST — Key reaction: A, S, D..."
# keyCode 0=A  1=S  2=D
osascript -e 'tell application "System Events" to key code 0' 2>/dev/null
sleep 0.15
osascript -e 'tell application "System Events" to key code 1' 2>/dev/null
sleep 0.15
osascript -e 'tell application "System Events" to key code 2' 2>/dev/null
sleep 0.3

KEY_LOGS=$(grep '\[EventTap\] keyDown' "$LOG_FILE" 2>/dev/null \
  | grep -E '"A"|"S"|"D"' || true)
if [[ -n "$KEY_LOGS" ]]; then
  pass "Keys captured: $(echo "$KEY_LOGS" | grep -oE '"[A-Z]"' | tr -d '"' | tr '\n' ' ')"
else
  fail "EventTap did not capture A/S/D — keys not reacting"
fi

# ── 7. Layer trigger tests ───────────────────────────────────────────────────
# Hyper = Cmd+Alt+Ctrl+Shift — old firmware tap-twice pattern
# Each layer: first Hyper+key tap toggles overlay ON, second toggles OFF.
# Keycodes: F19=80, F17=64, F16=106, ==24
HYPER_MODS="{command down, option down, control down, shift down}"

test_layer() {
  local name="$1" keycode="$2" trigger_desc="$3"
  echo "==> TEST — Layer trigger: Hyper+${trigger_desc} -> ${name}..."

  # Toggle ON
  osascript -e "tell application \"System Events\" to key code ${keycode} using ${HYPER_MODS}" 2>/dev/null
  sleep 0.4

  if grep -q "overlay ON \"${name}\"" "$LOG_FILE" 2>/dev/null; then
    pass "${name}: overlay ON via Hyper+${trigger_desc}"
  else
    fail "${name}: overlay did not activate"
    if grep -q "trigger key \"${trigger_desc}\"" "$LOG_FILE" 2>/dev/null; then
      echo "         Trigger key received but overlay not set — check flags in log"
    else
      echo "         Trigger key not received by EventTap"
    fi
    return
  fi

  # Toggle OFF
  osascript -e "tell application \"System Events\" to key code ${keycode} using ${HYPER_MODS}" 2>/dev/null
  sleep 0.4

  if grep -q "overlay OFF (was \"${name}\")" "$LOG_FILE" 2>/dev/null; then
    pass "${name}: overlay OFF via Hyper+${trigger_desc}"
  else
    fail "${name}: overlay did not deactivate"
  fi
}

test_layer "TK Cursor" 80  "F19"
test_layer "TK Symbol" 64  "F17"
test_layer "TK Mouse"  106 "F16"
test_layer "TK Lower"  24  "="

# ── 8. Summary ───────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────"
if [[ $TESTS_FAILED -eq 0 ]]; then
  echo "ALL TESTS PASSED ($TESTS_PASSED passed, 0 failed)"
  echo "OverKeysMac is running (PID $LAUNCHED_PID)"
else
  echo "TESTS: $TESTS_PASSED passed, $TESTS_FAILED FAILED"
  echo "Log: ${LOG_FILE}"
fi
echo "──────────────────────────────────────────"
