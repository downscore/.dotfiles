-- Set the leader key. Must be done before any mappings are set or plugins are loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Misc options.
vim.o.mouse = "a" -- Enable mouse support.
vim.g.have_nerd_font = true
vim.opt.number = true -- Enable line numbers.
vim.opt.undofile = true -- Save undo history.
vim.opt.updatetime = 250 -- Decrease update time.
vim.opt.timeoutlen = 500 -- Decrease mapped sequence wait time. Display which-key popup sooner.
vim.opt.splitright = true -- Configure how new splits should be opened.
vim.opt.splitbelow = true
vim.opt.signcolumn = "auto:1-4" -- Make gutter autoresize and allow it to get wider.
vim.opt.inccommand = "split" -- Preview substitutions while typing.
vim.opt.cursorline = true -- Highlight the line the cursor is on.
vim.opt.scrolloff = 10 -- Minimum number of screen lines to keep above and below the cursor.
vim.opt.colorcolumn = "101" -- Ruler just after line length limit.
vim.opt.wrap = false -- Disable line wrapping.
vim.opt.textwidth = 100 -- Set the maximum text width.
vim.g.python_recommended_style = false -- Disable Python recommended style.

-- Configure the terminal window title.
vim.opt.title = true
vim.opt.titlestring = "%F - neovim"

-- Set tabs to use 2 spaces.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Do not continue comments when pressing 'o' in normal mode.
vim.cmd("autocmd BufEnter * set formatoptions-=o")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=o")

-- Helper function for setting up keybindings.
function KB(mode, key, action, desc, noremap, silent)
  noremap = noremap or true
  silent = silent or true
  desc = desc or ""
  vim.keymap.set(mode, key, action, { noremap = noremap, silent = silent, desc = desc })
end

-- Keybindings for interacting with the system clipboard.
KB({ "n", "v", "x" }, "<leader>y", '"+y', "[Y]ank to system clipboard")
KB({ "n", "v", "x" }, "<leader>yy", '"+yy', "[Y]ank line to system clipboard")
KB({ "n", "v", "x" }, "<leader>Y", '"+Y', "[Y]ank line to system clipboard")
KB({ "n", "v", "x" }, "<leader>p", '"+p', "[P]aste from system clipboard")

-- Keybindings for inserting empty lines.
KB("n", "<leader>o", "o<Esc>", "Insert line below")
KB("n", "<leader>O", "O<Esc>", "Insert line above")
KB({ "n", "v", "x" }, "<C-M-o>", "o", "Insert line below")
KB("i", "<C-M-o>", "<C-o>o", "Insert line below in insert mode")

-- Search options.
vim.opt.ignorecase = true
vim.opt.smartcase = true -- Smart-case searching (ignore case if lowercase).
vim.opt.incsearch = true -- Incremental searching.
vim.opt.hlsearch = true -- Highlight search results.
KB("n", "<Esc>", "<cmd>nohlsearch<CR>", "[Esc] clears search highlights")

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Uncomment to use a default color scheme.
-- vim.cmd('colorscheme retrobox')

-- Diagnostic keymaps.
KB("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "[D]iagnostic: Go to previous")
KB("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", "[D]iagnostic: Go to next")
KB("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", "Diagnostic: [E]rrors")
KB("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", "Diagnostic: [Q]uickfix list")

-- Split keymaps.
-- Disable the default key bindings of vim-tmux-navigator so they don't overwrite our keybindings.
vim.g.tmux_navigator_no_mappings = 1
KB("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", "Go to left split")
KB("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", "Go to bottom split")
KB("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", "Go to top split")
KB("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", "Go to right split")
KB("n", "<C-p>", "<cmd>TmuxNavigatePrevious<CR>", "Go to previous split")
KB("n", "<C-BSlash>", "<cmd>vsplit<CR>", "Open a vertical split")
-- The following keymap allows using - without pressing shift.
KB("n", "<C-_>", "<cmd>split<CR>", "Open a horizontal split")
KB("n", "<C-x>", "<cmd>close<CR>", "Close the current split")

-- Navigate by word using option-left/right.
KB("n", "<M-Left>", "b", "Go to left one word")
KB("n", "<M-Right>", "w", "Go to right one word")
KB("i", "<M-Left>", "<C-o>b", "Go to left one word in insert mode")
KB("i", "<M-Right>", "<C-o>w", "Go to right one word in insert mode")
-- By default, option-up/down change from insert to normal mode. Make them stay in insert mode.
KB("i", "<M-Up>", "<Up>", "Move up in insert mode")
KB("i", "<M-Down>", "<Down>", "Move down in insert mode")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- to discover. You normally need to press <C-\><C-n>.
KB("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")

-- Allow toggling relative line numbers.
vim.opt.relativenumber = false -- Default relative line numbers setting.
KB("n", "<leader>tr", ":set relativenumber!<CR>", "[T]oggle [R]elative line numbers")

-- Add keybinding for toggling copilot.
local copilot_enabled = true
vim.api.nvim_create_user_command("CopilotToggle", function()
  if copilot_enabled then
    vim.cmd("Copilot disable")
  else
    vim.cmd("Copilot enable")
  end
  copilot_enabled = not copilot_enabled
  print("Copilot Enabled: " .. tostring(copilot_enabled))
end, { nargs = 0 })
KB("n", "<leader>tc", ":CopilotToggle<CR>", "[T]oggle [C]opilot")

-- Completion shortcuts.
KB("n", "<leader>cp", ":Copilot panel<CR>", "[C]opilot [P]anel")

-- Functionality for getting the editor context.
-- Helper function for getting the cursor index in the text.
function GetCursorIndex(text_before_length, cursor_line_length, cursor_col)
  -- Account for cursor column being 1-based.
  return text_before_length - (cursor_line_length - cursor_col + 1)
end
-- Copy the current mode and surrounding lines to the system clipboard.
function CopyEditorContext(current_mode)
  -- Get the current selection. Outside of visual mode, we just use the cursor position as the start
  -- and end of the selection.
  local cursor_line_from
  local cursor_line_to
  local cursor_col_from
  local cursor_col_to
  local cursor_line_length_from
  local cursor_line_length_to
  if current_mode == "v" then
    -- Get the visual selection range (1-based indices).
    cursor_line_from = vim.fn.line("'<")
    cursor_line_to = vim.fn.line("'>")
    cursor_col_from = vim.fn.col("'<")
    -- In insert mode, the cursor is before the character, but in visual mode the character is
    -- included in the selection, so we need to add 1 here.
    cursor_col_to = vim.fn.col("'>") + 1
    -- Swap the start and end if the selection is backwards.
    if
      cursor_line_from > cursor_line_to
      or (cursor_line_from == cursor_line_to and cursor_col_from > cursor_col_to)
    then
      cursor_line_from, cursor_line_to = cursor_line_to, cursor_line_from
      cursor_col_from, cursor_col_to = cursor_col_to, cursor_col_from
    end
    cursor_line_length_from = #vim.fn.getline(cursor_line_from)
    cursor_line_length_to = #vim.fn.getline(cursor_line_to)
  else
    cursor_line_from = vim.fn.line(".") -- 1-based.
    cursor_line_to = cursor_line_from
    cursor_col_from = vim.fn.col(".") -- 1-based.
    cursor_col_to = cursor_col_from
    cursor_line_length_from = vim.fn.col("$") - 1
    cursor_line_length_to = cursor_line_length_from
  end

  local doc_lines = vim.fn.line("$")
  local context_num_lines = 5 -- Returns this many lines before and after the cursor.

  -- Get text before the beginning and end of the selection.
  local line_before = math.max(1, cursor_line_from - context_num_lines)
  ---@diagnostic disable-next-line: param-type-mismatch
  local text_before_from = table.concat(vim.fn.getline(line_before, cursor_line_from), "\n")
  ---@diagnostic disable-next-line: param-type-mismatch
  local text_before_to = table.concat(vim.fn.getline(line_before, cursor_line_to), "\n")

  -- Compute the cursor positions in the text we will return.
  local cursor_index_from =
    GetCursorIndex(#text_before_from, cursor_line_length_from, cursor_col_from)
  local cursor_index_to = GetCursorIndex(#text_before_to, cursor_line_length_to, cursor_col_to)

  -- Get text after the cursor.
  local text_after = ""
  if cursor_line_to < doc_lines then
    local line_after = math.min(doc_lines, cursor_line_to + context_num_lines)
    ---@diagnostic disable-next-line: param-type-mismatch
    text_after = table.concat(vim.fn.getline(cursor_line_to + 1, line_after), "\n")
  end

  -- Combine mode and lines into a single string.
  local result = current_mode
    .. "\n"
    .. cursor_index_from
    .. "\n"
    .. cursor_index_to
    .. "\n"
    .. text_before_to
  if #text_after > 0 then
    result = result .. "\n" .. text_after
  end

  -- Copy to system clipboard.
  vim.fn.setreg("+", result)
end
-- Shortcuts in different modes to copy the mode and surrounding lines to the clipboard.
KB("n", "<C-s>", ':lua CopyEditorContext("n")<CR>', "Copy editor context to clipboard")
KB("v", "<C-s>", ':<C-u>lua CopyEditorContext("v")<CR>gv', "Copy editor context to clipboard")
KB("i", "<C-s>", '<C-o>:lua CopyEditorContext("i")<CR>', "Copy editor context to clipboard")

-- Highlight when yanking (copying) text.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore cursor when exiting or suspending neovim.
vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
  desc = "Restore cursor shape when exiting or suspending neovim",
  group = vim.api.nvim_create_augroup("kickstart-restore-cursor", { clear = true }),
  callback = function()
    vim.opt.guicursor = "a:ver25"
  end,
})

-- Install `lazy.nvim` plugin manager.
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim plugins.
local main_plugins = {
  -- Allows seamless navigation between tmux and nvim panes.
  { "christoomey/vim-tmux-navigator" },

  -- Catppuccin theme.
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Visualize marks.
  { "chentoast/marks.nvim" },

  -- Show keymaps.
  { "folke/which-key.nvim", event = "VeryLazy" },

  -- Easily changing brackets and surrounding text.
  { "tpope/vim-surround" },

  -- Use custom character for colorcolumn.
  {
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup()
    end,
  },

  -- Visible indentation lines.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "▏" },
      scope = { enabled = false },
    },
  },

  -- Git gutter.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      sign_priority = 6,
      signs = {
        change = { text = "▋" },
        changedelete = { text = "▋" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    },
  },

  -- Telescope fuzzy finder.
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      -- See `:help telescope` and `:help telescope.setup()`
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
        defaults = {
          file_ignore_patterns = { "node_modules", ".DS_Store", ".git" },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })
      pcall(require("telescope").load_extension, "ui-select")

      -- See `:help telescope.builtin`
      local builtin = require("telescope.builtin")
      KB("n", "<leader>sh", builtin.help_tags, "[S]earch [H]elp")
      KB("n", "<leader>sk", builtin.keymaps, "[S]earch [K]eymaps")
      KB("n", "<leader>sf", builtin.find_files, "[S]earch [F]iles")
      KB("n", "<leader>ss", builtin.builtin, "[S]earch [S]elect Telescope")
      KB("n", "<leader>sw", builtin.grep_string, "[S]earch current [W]ord")
      KB("n", "<leader>sg", builtin.live_grep, "[S]earch by [G]rep")
      KB("n", "<leader>sd", builtin.diagnostics, "[S]earch [D]iagnostics")
      KB("n", "<leader>sr", builtin.resume, "[S]earch [R]esume")
      KB("n", "<leader>s.", builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
      KB("n", "<leader><leader>", builtin.buffers, "[ ] Find existing buffers")
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch [/] in Open Files" })

      -- Shortcut for searching Neovim configuration files.
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({})
    end,
  },

  -- Integrated lf.
  {
    "lmburns/lf.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim" },
    config = function()
      -- This feature will not work if the plugin is lazy-loaded.
      vim.g.lf_netrw = 1

      require("lf").setup({
        escape_quit = true,
        winblend = 0,
        highlights = { NormalFloat = { guibg = "NONE" } },
        border = "rounded",
        direction = "float",
        height = vim.o.lines - 4,
        width = vim.o.columns - 4,
      })

      KB("n", "<leader>l", "<Cmd>Lf<CR>", "Integrated [L]f")
      KB("n", "<M-o>", "<Cmd>Lf<CR>", "Integrated Lf")
    end,
  },

  -- Lazydev Lua LSP for working with neovim APIs.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  -- LSP configuration.
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim.
      { "williamboman/mason.nvim", config = true }, -- Note: Must be loaded first.
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      -- Note: `opts = {}` is the same as calling `require('fidget').setup({})`
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      --  This function gets run when an LSP attaches to a buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- Helper function to define mappings specific to LSP related items. It sets the mode,
          -- buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- Find references for the word under your cursor.
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          -- Useful when you're not sure what type a variable is and you want to see the definition
          -- of its type.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

          -- Fuzzy find all the symbols in your current document.
          map(
            "<leader>ds",
            require("telescope.builtin").lsp_document_symbols,
            "[D]ocument [S]ymbols"
          )

          -- Fuzzy find all the symbols in your current workspace.
          map(
            "<leader>ws",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "[W]orkspace [S]ymbols"
          )

          -- Rename the variable under your cursor.
          -- Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error or a
          -- suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          -- Go to Declaration. In C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- The following two autocommands are used to highlight references of the word under your
          -- cursor when your cursor rests there for a little while. When you move your cursor, the
          -- highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
          then
            local highlight_augroup =
              vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = "kickstart-lsp-highlight",
                  buffer = event2.buf,
                })
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints, if the current language
          -- server supports them.
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- Change the Diagnostic symbols.
      local diagnostic_signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(diagnostic_signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- LSP servers and clients are able to communicate to each other what features they support.
      -- Create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities =
        vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Language server configuration. They will not be automatically installed.
      local servers = {
        -- gopls = {},
        asm_lsp = {
          filetypes = { "asm", "vmasm", "s" },
          root_dir = require("lspconfig").util.find_git_ancestor,
        },
        clangd = {
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              -- Uncomment to ignore Lua_LS's noisy `missing-fields` warnings.
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        pyright = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                disabled = {
                  "unlinked-file",
                },
              },
            },
          },
        },
        zls = {},
      }

      -- Configure servers above.
      require("mason").setup()
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed by the server configuration
            -- above. Useful when disabling certain features of an LSP (for example, turning off
            -- formatting for tsserver).
            server.capabilities =
              vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  -- Autoformat.
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fd",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't have a well standardized
        -- coding style. You can add additional languages here or re-enable it for the disabled
        -- ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = "never"
        else
          lsp_format_opt = "fallback"
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "yapf" }, -- Run multiple formatters sequentially.
      },
    },
  },

  -- Autocompletion.
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine and its associated nvim-cmp source.
      -- Note: Install jsregexp to enable variable transformations in snippets.
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Other completion capabilities.
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path", -- Source for file paths.
      "hrsh7th/cmp-buffer", -- Source for text in the current buffer.
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert,noselect" },
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.select_prev_item(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete({}), -- Manually trigger a completion from nvim-cmp.
          ["<C-e>"] = cmp.mapping.abort(), -- Abort completion.

          -- Bindings for scrolling the documentation window.
          -- TODO: Find unused keys for these mappings.
          -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          -- ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Move to the right and left of snippet expansions.
          ["<C-f>"] = cmp.mapping(function() --TODO
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-d>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        },
        sources = {
          {
            name = "lazydev",
            -- Set group index to 0 to skip loading LuaLS completions as lazydev recommends it.
            group_index = 0,
          },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        },
      })

      -- Define a function and keybinding to toggle autocomplete.
      local function toggle_autocomplete()
        local current_setting = cmp.get_config().completion.autocomplete
        local new_setting = not current_setting
        cmp.setup({
          completion = {
            autocomplete = new_setting,
          },
        })
        if new_setting then
          print("Autocomplete enabled")
        else
          print("Autocomplete disabled")
        end
      end
      vim.keymap.set(
        "n",
        "<leader>ta",
        toggle_autocomplete,
        { noremap = true, silent = true, desc = "[T]oggle [A]utocomplete" }
      )
    end,
  },

  -- Treesitter for better code highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- Sets main module to use for opts.
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        -- If you are experiencing weird indenting issues, add the language to the list of
        -- additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = { enable = true, disable = { "ruby" } },
    },
  },
}

-- Load private plugin configuration if available.
local private_plugins = {}
local private_plugins_path = os.getenv("HOME") .. "/.private_plugins.lua"
local function file_exists(file)
  local f = io.open(file, "r")
  if f then
    f:close()
  end
  return f ~= nil
end
if file_exists(private_plugins_path) then
  private_plugins = dofile(private_plugins_path)
end

-- Load all plugins.
function TableConcat(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end
local plugins = TableConcat(main_plugins, private_plugins)
require("lazy").setup(plugins)

-- Load the Catppuccin theme.
require("catppuccin").setup({
  flavour = "mocha", -- auto, latte, frappe, macchiato, mocha
  background = { -- :h background
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false, -- Disables setting the background color.
  show_end_of_buffer = false, -- Shows the '~' characters after the end of buffers.
  term_colors = false, -- Sets terminal colors (e.g. `g:terminal_color_0`).
  dim_inactive = {
    enabled = false, -- Dims the background color of inactive window.
    shade = "dark",
    percentage = 0.15, -- Percentage of the shade to apply to the inactive window.
  },
  no_italic = false, -- Force no italic.
  no_bold = false, -- Force no bold.
  no_underline = false, -- Force no underline.
  styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" }, -- Change the style of comments.
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
    -- miscs = {},  -- Uncomment to turn off hard-coded styles.
  },
  color_overrides = {},
  custom_highlights = {},
  default_integrations = true,
  integrations = {
    gitsigns = true,
    nvimtree = true,
    cmp = true,
    treesitter = true,
    native_lsp = {
      enabled = true,
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
  },
})
vim.cmd.colorscheme("catppuccin")

-- Configure marks plugin.
require("marks").setup({
  default_mappings = true, -- Default keybindings.
  -- builtin_marks = { ".", "<", ">", "^" }, -- Uncomment to show built-in marks.
  cyclic = true, -- Movements cycle back to beginning/end of buffer.
  sign_priority = { lower = 10, upper = 10, builtin = 10, bookmark = 10 },
})

-- Load external configuration file if it exists.
local private_init_path = os.getenv("HOME") .. "/.private_init.lua"
if file_exists(private_init_path) then
  private_plugins = dofile(private_init_path)
end
