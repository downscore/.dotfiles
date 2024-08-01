-- Set the leader key.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable mouse support.
vim.o.mouse = 'a'

-- Enable nerd fonts.
vim.g.have_nerd_font = false

-- Enable line numbers.
vim.opt.number = true
-- Uncomment for relative line numbers.
-- vim.opt.relativenumber = true

-- Set tabs to use 2 spaces.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Use system clipboard.
vim.opt.clipboard = 'unnamedplus'

-- Save undo history.
vim.opt.undofile = true

-- Smart-case searching.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep gutter ("sign") column.
vim.opt.signcolumn = 'yes'

-- Decrease update time.
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time.
-- Displays which-key popup sooner.
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions while typing.
vim.opt.inccommand = 'split'

-- Highlight the line the cursor is on.
vim.opt.cursorline = true

-- Minimum number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Uncomment to use a default color scheme.
-- vim.cmd('colorscheme retrobox')

-- Set highlight on search, but clear on pressing <Esc> in normal mode.
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps.
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Split keymaps.
-- Disable the default key bindings of vim-tmux-navigator so they don't overwrite our split key bindings.
vim.g.tmux_navigator_no_mappings = 1
vim.api.nvim_set_keymap('n', '<C-h>', ':TmuxNavigateLeft<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', ':TmuxNavigateDown<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':TmuxNavigateUp<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':TmuxNavigateRight<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':TmuxNavigatePrevious<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-BSlash>', ':vsplit<CR>', { noremap = true, desc = 'Open a vertical split' })
-- The following keymap allows using - without pressing shift.
vim.keymap.set('n', '<C-_>', ':split<CR>', { noremap = true, desc = 'Open a horizontal split' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Install `lazy.nvim` plugin manager.
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Load `lazy.nvim` and install plugins.
require('lazy').setup({
  -- Allows seamless navigation between tmux and nvim panes.
  { "christoomey/vim-tmux-navigator", },

  -- Catppuccin theme.
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Mason (LSP manager).
  { "williamboman/mason.nvim" },

  -- Telescope fuzzy finder.
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        defaults = {
          file_ignore_patterns = { "node_modules", ".DS_Store", ".git" },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        }
      }
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
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
      require("nvim-tree").setup {}
    end,
  },
})

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
    -- miscs = {}, -- Uncomment to turn off hard-coded styles.
  },
  color_overrides = {},
  custom_highlights = {},
  default_integrations = true,
  integrations = {
    -- TODO: Enable more integrations when plugins installed.
    -- cmp = true,
    -- gitsigns = true,
    nvimtree = true,
    -- treesitter = true,
    -- notify = false,
    -- mini = {
    --   enabled = true,
    --   indentscope_color = "",
    -- },
  },
})
vim.cmd.colorscheme "catppuccin"

-- Load Mason.
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})
