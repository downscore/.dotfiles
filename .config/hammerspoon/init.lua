require("annotations")
require("browser")
require("ghostty")
require("notifications")
require("obsidian")
require("window_management")
hs.loadSpoon("RecursiveBinder")

-- Shortcut to reload Hammerspoon config.
hs.hotkey.bind({ "cmd", "ctrl" }, "r", function()
  hs.notify.new({ title = "Hammerspoon", informativeText = "Reloading config..." }):send()
  hs.reload()
end)

-- Helper function to bind a key for focusing an application by name.
function BindAppFocusKey(key, appName)
  hs.hotkey.bind({ "cmd", "ctrl" }, key, function()
    hs.application.launchOrFocus(appName)
  end)
end

-- Helper function to bind a key for focusing a browser tab by hostname.
function BindBrowserTabFocusKey(key, hostname)
  hs.hotkey.bind({ "cmd", "ctrl" }, key, function()
    FocusBrowserTabByHostname(hostname)
  end)
end

-- Bind a key to resize the current window to the full screen size.
hs.hotkey.bind({ "cmd", "ctrl" }, "z", MaximizeCurrentWindow)

-- Bind keys to move the focused window between screens.
hs.hotkey.bind({ "cmd", "ctrl" }, "1", function()
  MoveCurrentWindowToScreen(1)
  MaximizeCurrentWindow()
end)
hs.hotkey.bind({ "cmd", "ctrl" }, "2", function()
  MoveCurrentWindowToScreen(2)
  MaximizeCurrentWindow()
end)
hs.hotkey.bind({ "cmd", "ctrl" }, "3", function()
  MoveCurrentWindowToScreen(3)
  MaximizeCurrentWindow()
end)

-- Bind a key to close all OS notifications.
hs.hotkey.bind({ "ctrl", "alt" }, "w", CloseAllSystemNotifications)

-- Bind app/tab switching shortcuts.
BindAppFocusKey("a", "Google Chat")
hs.hotkey.bind({ "cmd", "ctrl" }, "b", FocusBrowser)
BindAppFocusKey("c", "Visual Studio Code")
BindBrowserTabFocusKey("d", "docs.google.com")
BindAppFocusKey("e", "Reminders")
BindAppFocusKey("f", "Finder")
BindBrowserTabFocusKey("g", "mail.google.com")
BindBrowserTabFocusKey("l", "calendar.google.com")
BindAppFocusKey("m", "Messages")
BindAppFocusKey("n", "Notes")
BindAppFocusKey("o", "Obsidian")
BindAppFocusKey("p", "ChatGPT")
BindAppFocusKey("t", "Ghostty")
BindBrowserTabFocusKey("y", "youtube.com")

-- Add switcher shortcuts using a leader key.
local singleKey = spoon.RecursiveBinder.singleKey
local switcherKeyMap = {
  [singleKey("a", "Slack")] = function()
    hs.application.launchOrFocus("Slack")
  end,
  [singleKey("b", "Books")] = function()
    hs.application.launchOrFocus("Books")
  end,
  [singleKey("c", "Claude")] = function()
    hs.application.launchOrFocus("Claude")
  end,
  [singleKey("d", "Discord")] = function()
    hs.application.launchOrFocus("Discord")
  end,
  [singleKey("e", "Elgato SD")] = function()
    hs.application.launchOrFocus("Elgato Stream Deck")
  end,
  [singleKey("f", "FaceTime")] = function()
    hs.application.launchOrFocus("FaceTime")
  end,
  [singleKey("g", "Google Chrome")] = function()
    hs.application.launchOrFocus("Google Chrome")
  end,
  [singleKey("i", "IINA")] = function()
    hs.application.launchOrFocus("IINA")
  end,
  [singleKey("j", "Anki")] = function()
    hs.application.launchOrFocus("Anki")
  end,
  [singleKey("k", "KeePassXC")] = function()
    hs.application.launchOrFocus("KeePassXC")
  end,
  [singleKey("m", "Act. Monitor")] = function()
    hs.application.launchOrFocus("Activity Monitor")
  end,
  [singleKey("n", "Night PDF")] = function()
    hs.application.launchOrFocus("nightPDF")
  end,
  [singleKey("p", "ProtonVPN")] = function()
    hs.application.launchOrFocus("ProtonVPN")
  end,
  [singleKey("r", "Kap")] = function()
    hs.application.launchOrFocus("Kap")
  end,
  [singleKey("s", "Settings+")] = {
    [singleKey("a", "Apple Pay")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preferences.wallet"')
    end,
    [singleKey("b", "Bluetooth")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preferences.Bluetooth"')
    end,
    [singleKey("d", "Displays")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.displays"')
    end,
    [singleKey("g", "General")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preferences.general"')
    end,
    [singleKey("k", "Keyboard")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.keyboard"')
    end,
    [singleKey("n", "Notifications")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.notifications"')
    end,
    [singleKey("p", "Printers")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.printfax"')
    end,
    [singleKey("s", "Sound")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.sound"')
    end,
    [singleKey("t", "Trackpad")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.trackpad"')
    end,
    [singleKey("u", "Update")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preferences.softwareupdate"')
    end,
    [singleKey("w", "Wi-Fi")] = function()
      hs.execute('open "x-apple.systempreferences:com.apple.preference.network"')
    end,
  },
  [singleKey("t", "Steam")] = function()
    hs.application.launchOrFocus("Steam")
  end,
  [singleKey("v", "Preview")] = function()
    hs.application.launchOrFocus("Preview")
  end,
}
hs.hotkey.bind({ "cmd", "ctrl" }, "s", spoon.RecursiveBinder.recursiveBind(switcherKeyMap))

local jumpKeyMap = {
  [singleKey("d", "Daily")] = function()
    ObsidianOpenDailyNote()
  end,
}
local obsidianDocs = ObsidianGetJumpDocsFromFile()
for _, doc in ipairs(obsidianDocs) do
  local key = singleKey(doc[1], doc[2])
  jumpKeyMap[key] = function()
    ObsidianOpenDoc(doc[2])
  end
end
hs.hotkey.bind({ "cmd", "ctrl" }, "j", spoon.RecursiveBinder.recursiveBind(jumpKeyMap))

-- Bind keys for drawing annotations.
hs.hotkey.bind({ "ctrl", "shift" }, "w", AnnotationsClearAll)
hs.hotkey.bind({ "ctrl", "shift" }, "z", AnnotationsDrawRectangle)
hs.hotkey.bind({ "ctrl", "shift" }, "x", AnnotationsDrawArrow)
hs.hotkey.bind({ "ctrl", "shift" }, "c", function()
  AnnotationsDrawCircle(50)
end)
hs.hotkey.bind({ "ctrl", "shift" }, "v", function()
  AnnotationsDrawCircle(100)
end)

-- Set up app-specific behavior.
local appEvents = {
  { "Ghostty", GhosttyOnFocus, GhosttyOnFocusLost },
}
local appWatcher = hs.application.watcher.new(function(appName, eventType)
  if eventType == hs.application.watcher.activated then
    for _, event in ipairs(appEvents) do
      if appName == event[1] then
        event[2]() -- Focus event
      else
        event[3]() -- Focus lost event
      end
    end
  elseif eventType == hs.application.watcher.deactivated then
    for _, event in ipairs(appEvents) do
      if appName == event[1] then
        event[3]() -- Focus lost event
      end
    end
  end
end)
appWatcher:start()
