-- Open Terminal Here
-- Opens Terminal.app in the folder shown by the frontmost Finder window.
-- Designed to be Cmd-dragged onto the Finder toolbar.

on run
	set targetPath to missing value

	tell application "Finder"
		if (count of Finder windows) > 0 then
			try
				-- Folder shown by the front window
				set targetPath to (POSIX path of (target of front Finder window as alias))
			end try
		end if
	end tell

	-- Fall back to the Desktop if no Finder window is open
	if targetPath is missing value then
		set targetPath to (POSIX path of (path to desktop folder))
	end if

	tell application "Terminal"
		activate
		do script "cd " & quoted form of targetPath
	end tell
end run
