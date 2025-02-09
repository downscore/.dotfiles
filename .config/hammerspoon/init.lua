require("browser")
require("notifications")
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
end)
hs.hotkey.bind({ "cmd", "ctrl" }, "2", function()
  MoveCurrentWindowToScreen(2)
end)
hs.hotkey.bind({ "cmd", "ctrl" }, "3", function()
  MoveCurrentWindowToScreen(3)
end)

-- Bind a key to close all OS notifications.
hs.hotkey.bind({ "ctrl", "alt" }, "w", CloseAllSystemNotifications)

-- Bind app/tab switching shortcuts.
BindAppFocusKey("a", "Google Chat")
BindAppFocusKey("b", "Safari")
BindAppFocusKey("c", "Visual Studio Code")
BindBrowserTabFocusKey("d", "docs.google.com")
BindAppFocusKey("f", "Finder")
BindBrowserTabFocusKey("g", "mail.google.com")
BindBrowserTabFocusKey("l", "calendar.google.com")
BindAppFocusKey("m", "Messages")
BindAppFocusKey("o", "Obsidian")
BindAppFocusKey("p", "ChatGPT")
BindAppFocusKey("t", "Ghostty")
BindBrowserTabFocusKey("y", "youtube.com")

-- Add switcher shortcuts using a leader key.
local singleKey = spoon.RecursiveBinder.singleKey
local switcherKeyMap = {
  [singleKey("a", "Anki")] = function()
    hs.application.launchOrFocus("Anki")
  end,
  [singleKey("c", "Claude")] = function()
    hs.application.launchOrFocus("Claude")
  end,
  [singleKey("i", "IINA")] = function()
    hs.application.launchOrFocus("IINA")
  end,
  [singleKey("k", "KeePassXC")] = function()
    hs.application.launchOrFocus("KeePassXC")
  end,
  [singleKey("m", "Act. Monitor")] = function()
    hs.application.launchOrFocus("Activity Monitor")
  end,
  [singleKey("n", "Notes")] = function()
    hs.application.launchOrFocus("Notes")
  end,
  [singleKey("p", "ProtonVPN")] = function()
    hs.application.launchOrFocus("ProtonVPN")
  end,
  [singleKey("r", "Reminders")] = function()
    hs.application.launchOrFocus("Reminders")
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
}
hs.hotkey.bind({ "cmd", "ctrl" }, "s", spoon.RecursiveBinder.recursiveBind(switcherKeyMap))
