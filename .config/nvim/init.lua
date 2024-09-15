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
vim.opt.signcolumn = "yes" -- Enable gutter ("sign column").
vim.opt.signcolumn = "auto:2-9" -- Make gutter autoresize and allow it to get wider.
vim.opt.inccommand = "split" -- Preview substitutions while typing.
vim.opt.cursorline = true -- Highlight the line the cursor is on.
vim.opt.scrolloff = 10 -- Minimum number of screen lines to keep above and below the cursor.
vim.opt.colorcolumn = "101" -- Ruler just after line length limit.

-- Configure the terminal window title.
vim.opt.title = true
vim.opt.titlestring = "%F - neovim"

-- Set tabs to use 2 spaces.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Use system clipboard.
vim.opt.clipboard = "unnamedplus"
-- Prevent d* commands from modifying the system clipboard by remapping them to "_d*.
vim.api.nvim_set_keymap("n", "dd", '"_dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "d$", '"_d$', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "d0", '"_d0', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "d^", '"_d^', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dgg", '"_dgg', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dG", '"_dG', { noremap = true, silent = true })
-- Prevent x from modifying the system clipboard by remapping it to "_x.
vim.api.nvim_set_keymap("n", "x", '"_x', { noremap = true, silent = true })

-- Search options.
vim.opt.ignorecase = true
vim.opt.smartcase = true -- Smart-case searching (ignore case if lowercase).
vim.opt.incsearch = true -- Incremental searching.
vim.opt.hlsearch = true -- Highlight search results.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search highlights with <Esc>.

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Uncomment to use a default color scheme.
-- vim.cmd('colorscheme retrobox')

-- Diagnostic keymaps.
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
  desc = "Go to previous [D]iagnostic message",
})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
  desc = "Go to next [D]iagnostic message",
})
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
  desc = "Show diagnostic [E]rror messages",
})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {
  desc = "Open diagnostic [Q]uickfix list",
})

-- Split keymaps.
-- Disable the default key bindings of vim-tmux-navigator so they don't overwrite our keybindings.
vim.g.tmux_navigator_no_mappings = 1
vim.api.nvim_set_keymap("n", "<C-h>", ":TmuxNavigateLeft<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":TmuxNavigateDown<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":TmuxNavigateUp<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", ":TmuxNavigateRight<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-p>", ":TmuxNavigatePrevious<cr>", {
  noremap = true,
  silent = true,
})
vim.keymap.set("n", "<C-BSlash>", ":vsplit<CR>", { noremap = true, desc = "Open a vertical split" })
-- The following keymap allows using - without pressing shift.
vim.keymap.set("n", "<C-_>", ":split<CR>", { noremap = true, desc = "Open a horizontal split" })
vim.keymap.set("n", "<C-M-l>", ":vsplit<CR>", { noremap = true, desc = "Open a vertical split" })
vim.keymap.set("n", "<C-M-j>", ":split<CR>", { noremap = true, desc = "Open a horizontal split" })
vim.keymap.set("n", "<C-x>", ":close<CR>", { noremap = true, desc = "Close the current split" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- to discover. You normally need to press <C-\><C-n>.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Allow toggling relative line numbers.
vim.opt.relativenumber = true -- Enable relative line numbers by default.
vim.api.nvim_set_keymap("n", "<leader>tr", ":set relativenumber!<CR>", {
  noremap = true,
  silent = true,
})

-- Functionality for implementing textflow.
-- Helper function for getting the cursor index in the text.
function GetCursorIndex(text_before_length, cursor_line_length, cursor_col)
  -- Account for cursor column being 1-based.
  return text_before_length - (cursor_line_length - cursor_col + 1)
end
-- Copy the current mode and surrounding lines to the system clipboard.
function CopyTextflowContext(current_mode)
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
    .. ","
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
vim.api.nvim_set_keymap(
  "n",
  "<C-s>",
  ':lua CopyTextflowContext("n")<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "v",
  "<C-s>",
  ':<C-u>lua CopyTextflowContext("v")<CR>gv',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "i",
  "<C-s>",
  '<C-o>:lua CopyTextflowContext("i")<CR>',
  { noremap = true, silent = true }
)

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

-- Load `lazy.nvim` and install plugins.
require("lazy").setup({
  -- Allows seamless navigation between tmux and nvim panes.
  { "christoomey/vim-tmux-navigator" },

  -- Catppuccin theme.
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Visualize marks.
  { "chentoast/marks.nvim" },

  -- Use custom character for colorcolumn.
  {
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup()
    end,
  },

  -- Git gutter.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      sign_priority = 6,
      signs = {
        change = { text = "󰜛" },
        changedelete = { text = "󰜛" },
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
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, {
        desc = '[S]earch Recent Files ("." for repeat)',
      })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
        desc = "[ ] Find existing buffers",
      })
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

      -- Shortcut for searching your Neovim configuration files
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

      vim.keymap.set("n", "<leader>ff", "<Cmd>Lf<CR>")
      vim.keymap.set("n", "<M-o>", "<Cmd>Lf<CR>")
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

      -- LSP servers and clients are able to communicate to each other what features they support.
      -- Create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities =
        vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Language server configuration. They will not be automatically installed.
      local servers = {
        -- gopls = {},
        -- rust_analyzer = {},
        asm_lsp = {
          filetypes = { "asm", "vmasm", "s" },
          root_dir = require("lspconfig").util.find_git_ancestor,
        },
        clangd = {},
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
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
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

      -- Adds other completion capabilities.
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
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
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          -- Select the next/previous items.
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          -- Scroll the documentation window back/forward.
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          -- Tab to accept completions.
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),
          -- Uncomment to use enter to accept completions.
          -- ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- Manually trigger a completion from nvim-cmp.
          ["<C-Space>"] = cmp.mapping.complete({}),

          -- Move to the right and left of snippet expansions.
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        }),
        sources = {
          {
            name = "lazydev",
            -- Set group index to 0 to skip loading LuaLS completions as lazydev recommends it.
            group_index = 0,
          },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
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
      vim.keymap.set("n", "<leader>ta", toggle_autocomplete, { noremap = true, silent = true })
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
}) -- require('lazy').setup()

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
