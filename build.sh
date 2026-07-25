#!/bin/bash
# Builds the Finder-toolbar apps from their AppleScript sources.
# Produces native universal (arm64 + x86_64) apps, applies the icon, and ad-hoc signs them.
set -euo pipefail

cd "$(dirname "$0")"

ICON="src/icon.icns"

build_app() {
  local APP="$1" SRC="$2" BUNDLE_ID="$3" NAME="$4"

  echo "==> Compiling $SRC"
  rm -rf "$APP"
  osacompile -o "$APP" "$SRC"

  echo "==> Configuring Info.plist"
  local PLIST="$APP/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :LSUIElement true" "$PLIST"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$PLIST"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $NAME" "$PLIST" 2>/dev/null || true

  if [ -f "$ICON" ]; then
    echo "==> Setting bundle icon"
    cp "$ICON" "$APP/Contents/Resources/applet.icns"
  fi

  # Strip any stray Finder metadata before signing (codesign rejects "detritus").
  xattr -cr "$APP"

  echo "==> Ad-hoc signing"
  codesign --force --deep -s - "$APP"

  echo "==> Done: $APP"
}

build_app "Open Terminal Here (Universal).app" "src/OpenTerminalHere.applescript" \
  com.local.openterminalhere "Open Terminal Here"

build_app "Open iTerm2 Here (Universal).app" "src/OpenITerm2Here.applescript" \
  com.local.openiterm2here "Open iTerm2 Here"

echo
echo "Tip: if Finder shows a generic icon due to caching, run:"
echo "     ./set-local-icon.sh"
