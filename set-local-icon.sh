#!/bin/bash
# Optional: force Finder to show the app's icon immediately on THIS machine.
# Writes a custom-icon Finder resource (metadata only, not committed to git).
# Not needed on a fresh download — the bundle icon shows on its own there.
set -euo pipefail
cd "$(dirname "$0")"

APP="Open Terminal Here (Universal).app"
ICON="src/icon.icns"

osascript - "$PWD/$ICON" "$PWD/$APP" <<'OSA'
use framework "Foundation"
use framework "AppKit"
on run argv
	set img to current application's NSImage's alloc()'s initWithContentsOfFile:(item 1 of argv)
	current application's NSWorkspace's sharedWorkspace()'s setIcon:img forFile:(item 2 of argv) options:0
end run
OSA
echo "Local Finder icon applied to $APP"
