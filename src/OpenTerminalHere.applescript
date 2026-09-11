-- Open Terminal Here
-- Opens Terminal.app in the folder for the current Finder selection, or the
-- folder shown by the frontmost Finder window if nothing is selected.
-- Mirrors the classic "cd to" behavior: a selected file opens its containing
-- folder (even inside an expanded list-view subfolder), a selected folder
-- opens itself, and an alias resolves to its original item first.
-- Designed to be Cmd-dragged onto the Finder toolbar.

on run
	set targetPath to missing value

	tell application "Finder"
		-- Selection first
		try
			set sel to selection
			if (count of sel) > 0 then
				set selItem to item 1 of sel
				if class of selItem is alias file then
					set selItem to original item of selItem
				end if
				if class of selItem is folder or class of selItem is disk then
					set targetPath to POSIX path of (selItem as alias)
				else
					set targetPath to POSIX path of ((container of selItem) as alias)
				end if
			end if
		end try

		-- Fall back to the folder shown by the front window
		if targetPath is missing value then
			if (count of Finder windows) > 0 then
				try
					set targetPath to (POSIX path of (target of front Finder window as alias))
				end try
			end if
		end if
	end tell

	-- Fall back to the Desktop if no selection and no Finder window
	if targetPath is missing value then
		set targetPath to (POSIX path of (path to desktop folder))
	end if

	-- If Terminal isn't running yet, launch it and let its startup window's
	-- shell finish init (including any tmux auto-attach) BEFORE dropping the
	-- flag below — otherwise that shell races ours for the flag, wins, and
	-- the cd window ends up inside tmux instead of a plain shell.
	if application "Terminal" is not running then
		tell application "Terminal" to activate
		repeat 25 times
			tell application "Terminal"
				if (count of windows) > 0 then exit repeat
			end tell
			delay 0.2
		end repeat
		delay 0.5
	end if

	-- Drop a short-lived flag so a tmux auto-attach in the user's zshrc can
	-- skip itself for this window (see README); harmless if zshrc ignores it.
	do shell script "touch \"/tmp/opentermhere-skip-tmux-$USER\""

	tell application "Terminal"
		activate
		do script "cd " & quoted form of targetPath
	end tell
end run
