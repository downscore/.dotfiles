-- Global state: Whether to use Chrome or Safari.
-- Checking if Chrome is running on key presses is slow, so we check if Chrome is running when the
-- config is loaded.
UseChrome = hs.application.find("Google Chrome") ~= nil

-- Use AppleScript to find and focus the Safari tab with the matching hostname.
function FocusSafariTabByHostname(targetHostname)
  local appleScript = string.format(
    [[
        tell application "Safari"
            activate
            set foundTab to false
            repeat with w in windows
                set i to 0
                repeat with t in tabs of w
                    set i to i + 1
                    set tabURL to URL of t
                    if tabURL contains "%s" then
                        set current tab of w to t
                        set index of w to 1 -- Bring the window to the front
                        set foundTab to true
                        exit repeat
                    end if
                end repeat
                if foundTab then exit repeat
            end repeat
        end tell
    ]],
    targetHostname
  )
  local success = hs.osascript.applescript(appleScript)
  if not success then
    hs.notify
      .new({
        title = "Safari Tab Switch",
        informativeText = "No matching tab found for: " .. targetHostname,
      })
      :send()
  end
end

-- Use AppleScript to find and focus the Chrome tab with the matching hostname.
function FocusChromeTabByHostname(targetHostname)
  local appleScript = string.format(
    [[
        tell application "Google Chrome"
            activate
            set foundTab to false
            repeat with w in windows
                set i to 0
                repeat with t in tabs of w
                    set i to i + 1
                    set tabURL to URL of t
                    if tabURL contains "%s" then
                        set active tab index of w to i
                        set index of w to 1 -- Bring the window to the front
                        set foundTab to true
                        exit repeat
                    end if
                end repeat
                if foundTab then exit repeat
            end repeat
        end tell
    ]],
    targetHostname
  )
  local success = hs.osascript.applescript(appleScript)
  if not success then
    hs.notify
      .new({
        title = "Chrome Tab Switch",
        informativeText = "No matching tab found for: " .. targetHostname,
      })
      :send()
  end
end

-- Focus the first browser tab with the given hostname.
function FocusBrowserTabByHostname(targetHostname)
  if UseChrome then
    FocusChromeTabByHostname(targetHostname)
  else
    FocusSafariTabByHostname(targetHostname)
  end
end
