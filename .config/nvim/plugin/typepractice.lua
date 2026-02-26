-- TypePractice: typing practice inside your real nvim config
-- ~/.config/nvim/plugin/typepractice.lua

local ns = vim.api.nvim_create_namespace("typepractice")
local samples_dir = vim.fn.stdpath("config") .. "/type-samples"

-- Active session state (nil when no session)
local session = nil

-- Forward declaration
local start_session

-- Characters auto-inserted by autopairs (not counted as mistakes)
local autopair_close = { [")"] = true, ["]"] = true, ["}"] = true, ['"'] = true, ["'"] = true, ["`"] = true }

-- Strip trailing whitespace from a string
local function rstrip(s)
  return s:gsub("%s+$", "")
end

-- Strip trailing empty lines from a list of lines
local function strip_trailing_empty(lines)
  local result = vim.deepcopy(lines)
  while #result > 0 and result[#result]:match("^%s*$") do
    table.remove(result)
  end
  return result
end

-- Pick a sample file from the samples directory
local function pick_sample(arg)
  local files = {}
  local handle = vim.uv.fs_scandir(samples_dir)
  if not handle then
    vim.notify("TypePractice: no samples directory at " .. samples_dir, vim.log.levels.ERROR)
    return nil, nil
  end
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if typ == "file" and not name:match("^%.") then
      table.insert(files, name)
    end
  end
  if #files == 0 then
    vim.notify("TypePractice: no sample files found in " .. samples_dir, vim.log.levels.ERROR)
    return nil, nil
  end

  -- Filter or select
  if arg and arg ~= "" then
    -- Check for exact filename match first
    for _, f in ipairs(files) do
      if f == arg then
        local path = samples_dir .. "/" .. f
        local lines = vim.fn.readfile(path)
        local ext = f:match("%.([^%.]+)$") or ""
        local ft = vim.filetype.match({ filename = f }) or ext
        return lines, ft
      end
    end
    -- Filter by extension pattern
    local filtered = {}
    for _, f in ipairs(files) do
      if f:match("%." .. vim.pesc(arg) .. "$") then
        table.insert(filtered, f)
      end
    end
    if #filtered == 0 then
      vim.notify("TypePractice: no samples matching *." .. arg, vim.log.levels.WARN)
      return nil, nil
    end
    files = filtered
  end

  -- Random pick
  math.randomseed(os.clock() * 1000 + os.time())
  local chosen = files[math.random(#files)]
  local path = samples_dir .. "/" .. chosen
  local lines = vim.fn.readfile(path)
  local ext = chosen:match("%.([^%.]+)$") or ""
  local ft = vim.filetype.match({ filename = chosen }) or ext
  return lines, ft
end

-- Compute per-character diff and return highlight ranges + stats
local function compute_diff(ref_lines, typed_lines)
  local highlights = {} -- { {line, col_start, col_end, group} }
  local correct = 0
  local total_ref = 0
  local total_typed = 0

  local ref = strip_trailing_empty(ref_lines)
  local typed = strip_trailing_empty(typed_lines)

  for i = 1, math.max(#ref, #typed) do
    local ref_line = ref[i] or ""
    local typed_line = typed[i] or ""
    -- Strip trailing whitespace for comparison
    local ref_trimmed = rstrip(ref_line)
    local typed_trimmed = rstrip(typed_line)

    total_ref = total_ref + #ref_trimmed

    if i > #ref then
      -- Extra line typed that shouldn't exist
      total_typed = total_typed + #typed_trimmed
      if #typed_trimmed > 0 then
        table.insert(highlights, { i - 1, 0, #typed_line, "TypePracticeError" })
      end
    elseif i > #typed then
      -- Missing line (not typed yet) — don't highlight, just count
    else
      total_typed = total_typed + #typed_trimmed
      local len = math.max(#ref_trimmed, #typed_trimmed)
      local err_start = nil
      for j = 0, len - 1 do
        local rc = ref_trimmed:sub(j + 1, j + 1)
        local tc = typed_trimmed:sub(j + 1, j + 1)
        local is_err = (rc ~= tc) or (j >= #ref_trimmed) or (j >= #typed_trimmed)

        if is_err and j < #typed_trimmed then
          if not err_start then err_start = j end
          -- Count correct only when both chars exist and match
        else
          if err_start then
            table.insert(highlights, { i - 1, err_start, j, "TypePracticeError" })
            err_start = nil
          end
          if rc == tc and j < #ref_trimmed and j < #typed_trimmed then
            correct = correct + 1
          end
        end
      end
      if err_start then
        table.insert(highlights, { i - 1, err_start, math.max(#typed_trimmed, #ref_trimmed), "TypePracticeError" })
      end
    end
  end

  return highlights, correct, total_ref
end

-- Brief green highlight on the typed text on completion
local function flash_completion()
  if not session or not vim.api.nvim_buf_is_valid(session.type_buf) then return end
  local buf = session.type_buf
  local flash_ns = vim.api.nvim_create_namespace("typepractice_flash")
  vim.api.nvim_set_hl(0, "TypePracticeComplete", { fg = "#a6e3a1", bold = true })
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    if #line > 0 then
      vim.api.nvim_buf_set_extmark(buf, flash_ns, i - 1, 0, {
        end_col = #line,
        hl_group = "TypePracticeComplete",
      })
    end
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, flash_ns, 0, -1)
    end
  end, 800)
end

-- Update the status bar buffer
local function update_status()
  if not session or not vim.api.nvim_buf_is_valid(session.status_buf) then return end

  local elapsed = 0
  if session.start_time then
    elapsed = (vim.uv.hrtime() - session.start_time) / 1e9
  end

  local typed_lines = vim.api.nvim_buf_get_lines(session.type_buf, 0, -1, false)
  local highlights, correct, total_ref = compute_diff(session.ref_lines, typed_lines)

  -- Apply highlights to typing buffer
  vim.api.nvim_buf_clear_namespace(session.type_buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    local line, col_start, col_end, group = hl[1], hl[2], hl[3], hl[4]
    local buf_lines = vim.api.nvim_buf_line_count(session.type_buf)
    if line < buf_lines then
      local line_text = vim.api.nvim_buf_get_lines(session.type_buf, line, line + 1, false)[1] or ""
      -- Clamp col_end to actual line length
      local clamped_end = math.min(col_end, #line_text)
      if col_start < clamped_end then
        vim.api.nvim_buf_set_extmark(session.type_buf, ns, line, col_start, {
          end_col = clamped_end,
          hl_group = group,
        })
      end
    end
  end

  -- Track mistakes: only the start of each error span counts
  -- Typing more chars after a mistake extends the span, not a new mistake
  local cur_error_starts = {}
  for _, hl in ipairs(highlights) do
    local line, col_start = hl[1], hl[2]
    local line_text = typed_lines[line + 1] or ""
    if col_start < #line_text then
      local key = line .. ":" .. col_start
      local char = line_text:sub(col_start + 1, col_start + 1)
      cur_error_starts[key] = char
    end
  end
  for key, char in pairs(cur_error_starts) do
    if not autopair_close[char] and session.prev_error_starts[key] ~= char then
      session.mistakes = session.mistakes + 1
    end
  end
  session.prev_error_starts = cur_error_starts

  -- Compute WPM and accuracy
  local wpm_str = "--"
  local acc_str = "--"
  if session.start_time and elapsed > 0 then
    local wpm = (correct / 5) / (elapsed / 60)
    wpm_str = string.format("%.0f", wpm)
  end
  if total_ref > 0 then
    local acc = (correct / total_ref) * 100
    acc_str = string.format("%.1f%%", acc)
  end
  local time_str = string.format("%.1fs", elapsed)

  local status_line = string.format("  WPM: %s  Accuracy: %s  Mistakes: %d  Time: %s", wpm_str, acc_str, session.mistakes, time_str)

  vim.bo[session.status_buf].modifiable = true
  vim.api.nvim_buf_set_lines(session.status_buf, 0, -1, false, { status_line })
  vim.bo[session.status_buf].modifiable = false

  -- Check completion
  local ref_stripped = strip_trailing_empty(session.ref_lines)
  local typed_stripped = strip_trailing_empty(typed_lines)
  if #typed_stripped >= #ref_stripped and #ref_stripped > 0 then
    local complete = true
    for i = 1, #ref_stripped do
      if rstrip(typed_stripped[i] or "") ~= rstrip(ref_stripped[i]) then
        complete = false
        break
      end
    end
    -- Also check no extra non-empty lines
    for i = #ref_stripped + 1, #typed_stripped do
      if rstrip(typed_stripped[i]) ~= "" then
        complete = false
        break
      end
    end
    if complete and not session.completed then
      session.completed = true
      local summary = string.format(
        "  Done!  WPM: %s  Accuracy: %s  Mistakes: %d  Time: %s  [<CR> next | q quit]",
        wpm_str, acc_str, session.mistakes, time_str
      )
      vim.bo[session.status_buf].modifiable = true
      vim.api.nvim_buf_set_lines(session.status_buf, 0, -1, false, { summary })
      vim.bo[session.status_buf].modifiable = false
      vim.schedule(function()
        if session then
          flash_completion()
          vim.cmd("stopinsert")
        end
      end)
    end
  end
end

-- Clean up the session
local function cleanup()
  if not session then return end
  local s = session
  session = nil -- prevent re-entrancy

  -- Remove autocmds
  if s.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, s.augroup)
  end

  -- Close windows and wipe buffers
  for _, win in ipairs({ s.ref_win, s.type_win, s.status_win }) do
    if win and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  for _, buf in ipairs({ s.ref_buf, s.type_buf, s.status_buf }) do
    if buf and vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

-- Load next random sample (preserving filter)
local function next_sample()
  if not session then return end
  local filter = session.filter_arg
  local ref_lines, filetype = pick_sample(filter)
  if not ref_lines then return end
  ref_lines = strip_trailing_empty(ref_lines)
  if #ref_lines == 0 then return end
  start_session(ref_lines, filetype, filter)
end

-- Start a practice session
start_session = function(ref_lines, filetype, filter_arg)
  -- Clean up any existing session
  if session then cleanup() end

  -- Store original window to restore on quit
  local orig_win = vim.api.nvim_get_current_win()

  -- Create a new tab so we don't mess with the user's layout
  vim.cmd("tabnew")

  -- Reference buffer (left)
  local ref_buf = vim.api.nvim_get_current_buf()
  vim.bo[ref_buf].buftype = "nofile"
  vim.bo[ref_buf].bufhidden = "wipe"
  vim.bo[ref_buf].swapfile = false
  vim.api.nvim_buf_set_lines(ref_buf, 0, -1, false, ref_lines)
  vim.bo[ref_buf].modifiable = false
  vim.bo[ref_buf].readonly = true
  if filetype and filetype ~= "" then
    vim.bo[ref_buf].filetype = filetype
  end
  local ref_win = vim.api.nvim_get_current_win()
  vim.wo[ref_win].number = false
  vim.wo[ref_win].relativenumber = false
  vim.wo[ref_win].cursorline = false
  vim.wo[ref_win].signcolumn = "no"
  vim.wo[ref_win].foldcolumn = "0"

  -- Typing buffer (right)
  vim.cmd("vsplit")
  local type_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, type_buf)
  vim.bo[type_buf].buftype = "nofile"
  vim.bo[type_buf].bufhidden = "wipe"
  vim.bo[type_buf].swapfile = false
  if filetype and filetype ~= "" then
    vim.bo[type_buf].filetype = filetype
  end
  -- Disable Copilot
  vim.b[type_buf].copilot_enabled = false
  local type_win = vim.api.nvim_get_current_win()
  vim.wo[type_win].signcolumn = "no"
  vim.wo[type_win].foldcolumn = "0"

  -- Status bar (bottom)
  vim.cmd("botright 1split")
  local status_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, status_buf)
  vim.bo[status_buf].buftype = "nofile"
  vim.bo[status_buf].bufhidden = "wipe"
  vim.bo[status_buf].swapfile = false
  vim.bo[status_buf].modifiable = true
  vim.api.nvim_buf_set_lines(status_buf, 0, -1, false, { "  WPM: --  Accuracy: --  Mistakes: 0  Time: 0.0s" })
  vim.bo[status_buf].modifiable = false
  local status_win = vim.api.nvim_get_current_win()
  vim.wo[status_win].number = false
  vim.wo[status_win].relativenumber = false
  vim.wo[status_win].cursorline = false
  vim.wo[status_win].signcolumn = "no"
  vim.wo[status_win].foldcolumn = "0"
  vim.wo[status_win].statusline = " "
  vim.wo[status_win].winfixheight = true

  -- Set up error highlight group
  vim.api.nvim_set_hl(0, "TypePracticeError", { bg = "#ff1111", fg = "#ffffff" })

  -- Initialize session state
  session = {
    ref_buf = ref_buf,
    ref_win = ref_win,
    ref_lines = ref_lines,
    type_buf = type_buf,
    type_win = type_win,
    status_buf = status_buf,
    status_win = status_win,
    start_time = nil,
    completed = false,
    mistakes = 0,
    prev_error_starts = {},
    filter_arg = filter_arg,
    orig_win = orig_win,
    augroup = nil,
  }

  -- Create autocmd group
  local augroup = vim.api.nvim_create_augroup("TypePractice", { clear = true })
  session.augroup = augroup

  -- Start timer on first keystroke
  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = augroup,
    buffer = type_buf,
    once = true,
    callback = function()
      if session then
        session.start_time = vim.uv.hrtime()
      end
    end,
  })

  -- Update on text changes
  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    group = augroup,
    buffer = type_buf,
    callback = function()
      update_status()
    end,
  })

  -- q to quit, <CR> for next sample in both practice buffers
  for _, buf in ipairs({ ref_buf, type_buf }) do
    vim.keymap.set("n", "q", cleanup, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<CR>", next_sample, { buffer = buf, nowait = true })
  end

  -- Clean up if any practice buffer is wiped externally
  for _, buf in ipairs({ ref_buf, type_buf, status_buf }) do
    vim.api.nvim_create_autocmd("BufWipeout", {
      group = augroup,
      buffer = buf,
      once = true,
      callback = function()
        vim.schedule(cleanup)
      end,
    })
  end

  -- Focus the typing buffer and enter insert mode
  vim.api.nvim_set_current_win(type_win)
  vim.cmd("startinsert")
end

-- Command handler
local function type_practice_cmd(opts)
  local ref_lines, filetype

  local filter_arg = nil

  -- Check for visual selection (range)
  if opts.range == 2 then
    ref_lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    filetype = vim.bo.filetype
  else
    filter_arg = opts.args and opts.args ~= "" and opts.args or nil
    ref_lines, filetype = pick_sample(filter_arg)
    if not ref_lines then return end
  end

  -- Strip trailing empty lines from sample
  ref_lines = strip_trailing_empty(ref_lines)

  if #ref_lines == 0 then
    vim.notify("TypePractice: empty sample", vim.log.levels.WARN)
    return
  end

  start_session(ref_lines, filetype, filter_arg)
end

-- Register commands
vim.api.nvim_create_user_command("TypePractice", type_practice_cmd, {
  nargs = "?",
  range = true,
  complete = function(arglead)
    local completions = {}
    local handle = vim.uv.fs_scandir(samples_dir)
    if not handle then return completions end
    while true do
      local name, typ = vim.uv.fs_scandir_next(handle)
      if not name then break end
      if typ == "file" and not name:match("^%.") then
        if name:find(arglead, 1, true) == 1 or arglead == "" then
          table.insert(completions, name)
        end
        -- Also complete extensions
        local ext = name:match("%.([^%.]+)$")
        if ext and ext:find(arglead, 1, true) == 1 then
          if not vim.tbl_contains(completions, ext) then
            table.insert(completions, ext)
          end
        end
      end
    end
    table.sort(completions)
    return completions
  end,
})

vim.api.nvim_create_user_command("TypeQuit", function()
  if session then
    cleanup()
  else
    vim.notify("TypePractice: no active session", vim.log.levels.WARN)
  end
end, {})
