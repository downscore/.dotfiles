local ghosttyCtrlTabTap = nil
local tabKeyCode = hs.keycodes.map.tab

local function GhosttyIsFrontmost()
  local app = hs.application.frontmostApplication()
  return app and app:name() == "Ghostty"
end

local function GhosttyShouldHandleCtrlTab(event)
  if event:getKeyCode() ~= tabKeyCode then
    return false
  end

  local flags = event:getFlags()
  return flags.ctrl
    and not flags.alt
    and not flags.cmd
    and not flags.fn
    and not flags.shift
end

function GhosttyInitialize()
  if ghosttyCtrlTabTap then
    return
  end

  -- Make ctrl-tab switch to the previous window in tmux, but only in Ghostty.
  ghosttyCtrlTabTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    if not GhosttyIsFrontmost() or not GhosttyShouldHandleCtrlTab(event) then
      return false
    end

    hs.eventtap.keyStroke({ "ctrl" }, "b", 0)
    hs.eventtap.keyStroke({}, "o", 0)
    return true
  end)
  ghosttyCtrlTabTap:start()
end
