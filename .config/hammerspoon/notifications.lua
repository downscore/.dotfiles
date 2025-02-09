-- Close all notifications using Applescript.
function CloseAllSystemNotifications()
  -- AppleScript adapted from https://github.com/Ptujec/LaunchBar/
  local appleScript = [[
      property notificationTypes : {"AXNotificationCenterAlert", "AXNotificationCenterBanner"}
      property closeText : {"Close", "Clear All"}

      on run
        tell application "System Events"
          set _main_group to group 1 of scroll area 1 of group 1 of group 1 of window 1 of application process "NotificationCenter"
          set _headings to UI elements of _main_group whose role is "AXHeading"
          set _headingscount to count of _headings
        end tell

        repeat _headingscount times
          tell application "System Events" to set _roles to role of UI elements of _main_group
          set _headingIndex to its getIndexOfItem:"AXHeading" inList:_roles
          set _closeButtonIndex to _headingIndex + 1
          tell application "System Events" to click item _closeButtonIndex of UI elements of _main_group
          delay 0.2
        end repeat

        tell application "System Events"
          try
            set _groups to groups of _main_group
            if _groups is {} then
              if subrole of _main_group is in notificationTypes then
                set _actions to actions of _main_group
                repeat with _action in _actions
                  if description of _action is in closeText then
                    perform _action
                  end if
                end repeat
              end if
              return
            end if

            repeat with _group in _groups
              set _actions to actions of first item of _groups
              repeat with _action in _actions
                if description of _action is in closeText then
                  perform _action
                end if
              end repeat
            end repeat
          on error
            if subrole of _main_group is in notificationTypes then
              set _actions to actions of _main_group
              repeat with _action in _actions
                if description of _action is in closeText then
                  perform _action
                end if
              end repeat
            end if
          end try
        end tell
      end run

      on getIndexOfItem:anItem inList:aList
        set anArray to NSArray's arrayWithArray:aList
        set ind to ((anArray's indexOfObject:anItem) as number) + 1
        return ind
      end getIndexOfItem:inList:
    ]]
  local success = hs.osascript.applescript(appleScript)
  if not success then
    hs.notify
      .new({
        title = "Hammerspoon",
        informativeText = "Failed to close notifications",
      })
      :send()
  end
end
