local ghosttyHotkey = nil

function GhosttyOnFocus()
  if ghosttyHotkey then
    return
  end
  -- Make ctrl-tab switch to the previous window in tmux.
  ghosttyHotkey = hs.hotkey.bind({ "ctrl" }, "tab", function()
    hs.eventtap.keyStroke({ "ctrl" }, "b", 0)
    hs.eventtap.keyStroke({}, "o", 0)
  end)
end

function GhosttyOnFocusLost()
  if not ghosttyHotkey then
    return
  end
  ghosttyHotkey:delete()
  ghosttyHotkey = nil
end
