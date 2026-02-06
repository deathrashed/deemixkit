tell application "System Events"
	set isRunning to false
	set appList to (get name of every process)
	if appList contains "Deemix" then set isRunning to true
end tell

if isRunning is false then
	tell application "Deemix" to activate
	delay 1
end if

tell application "Deemix" to activate
delay 0.5

tell application "System Events"
	key code 48
	delay 0.1
	key code 48
	delay 0.1
	keystroke "v" using command down
	delay 0.1
	key up command
	delay 0.5
end tell

-- Show dialog with option to hide
display dialog "URLs pasted to Deemix. Hide the app?" buttons {"Keep Visible", "Hide"} default button "Hide" with title "DeemixKit"

if button returned of result is "Hide" then
	delay 0.5
	tell application "System Events"
		keystroke "h" using command down
	end tell
end if