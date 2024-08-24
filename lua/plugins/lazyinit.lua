local pluginList = nil
local nixLazyPath = nil
if require('nixCatsUtils').isNixCats then
  local allPlugins = require('nixCats').pawsible.allPlugins
  -- this list tells lazy.nvim not to download these plugins
  local pluginList = require('nixCatsUtils.lazyCat').mergePluginTables(allPlugins.start, allPlugins.opt)
  -- some have slightly different names
  pluginList[ [[Comment.nvim]] ] = ""
  pluginList[ [[LuaSnip]] ] = ""

  nixLazyPath = allPlugins.start[ [[lazy.nvim]] ]
end

local function getlockfilepath()
  if require('nixCats').isNixCats and type(require('nixCats').settings.unwrappedCfgPath) == "string" then
    return require('nixCats').settings.unwwrappedCfgPath .. "/lazy-lock.json"
  else
    return vim.fn.stdpath("config") .. "/lazy-lock.json"
  end
end

local lazyOptions = {
  lockfile = getlockfilepath(),
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}


-- Configure and install plugins
-- check status with :Lazy

require('nixCatsUtils.lazyCat').setup(pluginList, nixLazyPath, {
  'tpope/vim-sleuth',  -- just load

  -- name because the plugin name and the download name don't match
  -- opts = {} is the same as require('Comment').setup({})
  { 'numToStr/Comment.nvim', name = "comment.nvim", opts = {} },

  -- actually supply some options
  { 'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  { 'navarasu/onedark.nvim',
    priority = 1000, -- before other plugins
    init = function()
      vim.cmd.colorscheme 'onedark'
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  { -- show pending keybinds
    'folke/which-key.nvim',
    event = 'VimEnter',  -- the loading event
    config = function()  -- this function runs after loading
      require('which-key').setup()
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>r', group = '[R]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[S]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>t_', hidden = true },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>w_', hidden = true },
        {
          mode = { 'v' },
          { '<leader>h', group = 'Git [H]unk' },
          { '<leader>h_', hidden = true },
        },
      }
    end,
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = require('nixCatsUtils').lazyAdd('make'),
        cond = require('nixCatsUtils').lazyAdd(function()
          return vim.fn.executable 'make' == 1
        end),
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- :Telescope help_tags
      -- help - insert mode <c-/>, normal mode ?
      require('telescope').setup {
        -- :help telescope_setup()
        extensions = {
          [ 'ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      -- Enable telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- :help telescope.builtin
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

      -- override default behaviour and theme
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewr = false,
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = "[S]earch [/] in  Open Files"})

      -- search config files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = "[S]earch [N]eovim files" })
    end,
    },

}, lazyOptions)

-- modeline
-- vim: ts=2 sts=2 sw=2 et
