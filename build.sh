#!/bin/bash
# Builds "Open Terminal Here (Universal).app" from the AppleScript source.
# Produces a native universal (arm64 + x86_64) app, applies the icon, and ad-hoc signs it.
set -euo pipefail

cd "$(dirname "$0")"

APP="Open Terminal Here (Universal).app"
SRC="src/OpenTerminalHere.applescript"
ICON="src/icon.icns"

echo "==> Compiling $SRC"
rm -rf "$APP"
osacompile -o "$APP" "$SRC"

echo "==> Configuring Info.plist"
PLIST="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :LSUIElement true" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.local.openterminalhere" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.local.openterminalhere" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleName Open Terminal Here" "$PLIST" 2>/dev/null || true

if [ -f "$ICON" ]; then
  echo "==> Setting bundle icon"
  cp "$ICON" "$APP/Contents/Resources/applet.icns"
fi

# Strip any stray Finder metadata before signing (codesign rejects "detritus").
xattr -cr "$APP"

echo "==> Ad-hoc signing"
codesign --force --deep -s - "$APP"

echo "==> Done: $APP"
echo
echo "Tip: if Finder shows a generic icon due to caching, run:"
echo "     ./set-local-icon.sh"
