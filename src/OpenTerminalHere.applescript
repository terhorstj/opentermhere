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

	tell application "Terminal"
		activate
		do script "cd " & quoted form of targetPath
	end tell
end run
