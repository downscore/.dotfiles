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

function ObsidianGetJumpDocsFromFile()
  local path = os.getenv("HOME") .. "/obsidian_docs.csv"

  -- Make sure the file exists.
  local file = io.open(path, "r")
  if file == nil then
    hs.logger.new("obsidian.lua"):w("File not found: " .. path)
    return {}
  end

  -- Read the file.
  local result = {}
  local firstLine = true
  for line in file:lines() do
    -- Skip the first line (column names).
    if firstLine then
      firstLine = false
    else
      local lineElements = {}
      for field in string.gmatch(line, "([^,]+)") do
        table.insert(lineElements, field)
      end
      table.insert(result, lineElements)
    end
  end
  return result
end
