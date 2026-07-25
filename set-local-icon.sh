#!/bin/bash
# Optional: force Finder to show the apps' icon immediately on THIS machine.
# Writes a custom-icon Finder resource (metadata only, not committed to git).
# Not needed on a fresh download — the bundle icon shows on its own there.
set -euo pipefail
cd "$(dirname "$0")"

apply_icon() {
  local APP="$1" ICON="$2"
  [ -d "$APP" ] || return 0
  osascript - "$PWD/$ICON" "$PWD/$APP" <<'OSA'
use framework "Foundation"
use framework "AppKit"
on run argv
	set img to current application's NSImage's alloc()'s initWithContentsOfFile:(item 1 of argv)
	current application's NSWorkspace's sharedWorkspace()'s setIcon:img forFile:(item 2 of argv) options:0
end run
OSA
  echo "Local Finder icon applied to $APP"
}

apply_icon "Open Terminal Here (Universal).app" "src/icon.icns"
apply_icon "Open iTerm2 Here (Universal).app" "src/icon-iterm2.icns"
