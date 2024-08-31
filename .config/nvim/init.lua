-- Set the leader key. Must be done before any mappings are set or plugins are loaded.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Misc options.
vim.o.mouse = 'a'  -- Enable mouse support.
vim.g.have_nerd_font = true
vim.opt.number = true  -- Enable line numbers.
vim.opt.undofile = true  -- Save undo history.
vim.opt.updatetime = 250  -- Decrease update time.
vim.opt.timeoutlen = 500 -- Decrease mapped sequence wait time. Display which-key popup sooner.
vim.opt.splitright = true  -- Configure how new splits should be opened.
vim.opt.splitbelow = true
vim.opt.signcolumn = 'yes'  -- Enable gutter ("sign column").
vim.opt.signcolumn="auto:3-9"  -- Make gutter autoresize and allow it to get wider.
vim.opt.inccommand = 'split'  -- Preview substitutions while typing.
vim.opt.cursorline = true  -- Highlight the line the cursor is on.
vim.opt.scrolloff = 10  -- Minimum number of screen lines to keep above and below the cursor.

-- Set tabs to use 2 spaces.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Use system clipboard.
vim.opt.clipboard = 'unnamedplus'
-- Prevent d* commands from modifying the system clipboard by remapping them to "_d*.
vim.api.nvim_set_keymap('n', 'dd', '"_dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'd$', '"_d$', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'd0', '"_d0', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'd^', '"_d^', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dgg', '"_dgg', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dG', '"_dG', { noremap = true, silent = true })
-- Prevent x from modifying the system clipboard by remapping it to "_x.
vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true, silent = true })

-- Search options.
vim.opt.ignorecase = true
vim.opt.smartcase = true  -- Smart-case searching (ignore case if lowercase).
vim.opt.incsearch = true  -- Incremental searching.
vim.opt.hlsearch = true  -- Highlight search results.
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')  -- Clear search highlights with <Esc>.

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Uncomment to use a default color scheme.
-- vim.cmd('colorscheme retrobox')

-- Diagnostic keymaps.
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {
  desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {
  desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
  desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = 'Open diagnostic [Q]uickfix list' })

-- Split keymaps.
-- Disable the default key bindings of vim-tmux-navigator so they don't overwrite our keybindings.
vim.g.tmux_navigator_no_mappings = 1
vim.api.nvim_set_keymap('n', '<C-h>', ':TmuxNavigateLeft<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', ':TmuxNavigateDown<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':TmuxNavigateUp<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':TmuxNavigateRight<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', ':TmuxNavigatePrevious<cr>', {
  noremap = true, silent = true})
vim.keymap.set('n', '<C-BSlash>', ':vsplit<CR>', { noremap = true, desc = 'Open a vertical split' })
-- The following keymap allows using - without pressing shift.
vim.keymap.set('n', '<C-_>', ':split<CR>', { noremap = true, desc = 'Open a horizontal split' })
vim.keymap.set('n', '<C-M-l>', ':vsplit<CR>', { noremap = true, desc = 'Open a vertical split' })
vim.keymap.set('n', '<C-M-j>', ':split<CR>', { noremap = true, desc = 'Open a horizontal split' })
vim.keymap.set('n', '<C-x>', ':close<CR>', { noremap = true, desc = 'Close the current split' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- to discover. You normally need to press <C-\><C-n>.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Allow toggling relative line numbers.
vim.opt.relativenumber = true  -- Enable relative line numbers by default.
vim.api.nvim_set_keymap('n', '<Leader>l', ':set relativenumber!<CR>', {
  noremap = true, silent = true })

-- Highlight when yanking (copying) text
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

  -- Visualize marks.
  { "chentoast/marks.nvim" },

  -- Git gutter.
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      sign_priority = 6,
      signs = {
        change = { text = '󰜛' },
        changedelete = { text = '󰜛' },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align',  -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    },
  },

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
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
        desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, {
        desc = '[ ] Find existing buffers' })
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
    end
  },
})

-- Load the Catppuccin theme.
require("catppuccin").setup({
  flavour = "mocha",  -- auto, latte, frappe, macchiato, mocha
  background = {  -- :h background
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false,  -- Disables setting the background color.
  show_end_of_buffer = false,  -- Shows the '~' characters after the end of buffers.
  term_colors = false,  -- Sets terminal colors (e.g. `g:terminal_color_0`).
  dim_inactive = {
    enabled = false,  -- Dims the background color of inactive window.
    shade = "dark",
    percentage = 0.15,  -- Percentage of the shade to apply to the inactive window.
  },
  no_italic = false,  -- Force no italic.
  no_bold = false,  -- Force no bold.
  no_underline = false,  -- Force no underline.
  styles = {  -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" },  -- Change the style of comments.
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
    -- TODO: Enable more integrations when plugins installed.
    -- cmp = true,
    -- treesitter = true,
    -- notify = false,
    -- mini = {
    --   enabled = true,
    --   indentscope_color = "",
    -- },
  },
})
vim.cmd.colorscheme "catppuccin"

-- Configure Mason.
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- Configure marks plugin.
require("marks").setup {
  default_mappings = true,  -- Default keybindings.
  builtin_marks = { ".", "<", ">", "^" },  -- Which builtin marks to show.
  cyclic = true,  -- Movements cycle back to beginning/end of buffer.
  sign_priority = { lower=10, upper=10, builtin=10, bookmark=10 },
}
