-- Switch to Obsidian and open a document by name.
function ObsidianOpenDoc(name)
  hs.application.launchOrFocus("Obsidian")
  hs.eventtap.keyStroke({ "cmd" }, "o")
  hs.eventtap.keyStrokes(name)
  hs.eventtap.keyStroke({}, "return")
end

-- Switch to Obsidian and open today's daily note.
function ObsidianOpenDailyNote()
  hs.application.launchOrFocus("Obsidian")
  hs.eventtap.keyStroke({ "cmd", "shift" }, "p")
  hs.eventtap.keyStrokes("Daily notes: Open today's daily note")
  hs.eventtap.keyStroke({}, "return")
end
