-- Function to move the focused window to the given screen.
function MoveCurrentWindowToScreen(screenIndex)
  local win = hs.window.focusedWindow()
  if not win then
    hs.notify.new({ title = "Hammerspoon", informativeText = "No active window to move" }):send()
    return
  end
  local allScreens = hs.screen.allScreens()
  if screenIndex > #allScreens then
    hs.notify
      .new({ title = "Hammerspoon", informativeText = "Screen not found: " .. screenIndex })
      :send()
    return
  end
  local targetScreen = allScreens[screenIndex]
  win:moveToScreen(targetScreen)
end

-- Resize the current window to the full screen size.
function MaximizeCurrentWindow()
  local win = hs.window.focusedWindow()
  if win then
    local screenFrame = win:screen():frame()
    win:setFrame(screenFrame)
  else
    hs.notify.new({ title = "Hammerspoon", informativeText = "No active window to resize" }):send()
  end
end
