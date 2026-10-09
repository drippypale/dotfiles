-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- barber to add tabs
  -- {
  --   'romgrk/barbar.nvim',
  --   dependencies = {
  --     'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
  --     'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  --   },
  --   init = function()
  --     vim.g.barbar_auto_setup = false
  --   end,
  --   opts = {
  --     clickable = false,
  --   },
  --   version = '^1.0.0', -- optional: only update when a new 1.x version is released
  --   keys = {
  --     { '<Tab>', '<Cmd>BufferNext<CR>', desc = 'Go to the next buffer', silent = true, noremap = true },
  --     { '<S-Tab>', '<Cmd>BufferPrevious<CR>', desc = 'Go to the prev buffer', silent = true, noremap = true },
  --     { '<leader>x', '<Cmd>BufferClose<CR>', desc = 'Close the current buffer', silent = true, noremap = true },
  --   },
  -- },
  {
    -- This will help in navigation between tmux panes and neovim buffers
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>', desc = 'Go to the left pane' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>', desc = 'Go to the bottome pane' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>', desc = 'Go to the top pane' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>', desc = 'Go to the right pane' },
    },
  },

  {
    -- Git plugin
    'tpope/vim-fugitive',
  },

  {
    -- auto tag for html and stuff
    'windwp/nvim-ts-autotag',
    ft = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
    },
    opts = {},
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup {}

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[A]dd new item to the harpoon' })
      vim.keymap.set('n', '<leader>e', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon m[e]nu' })

      -- Harpoon Buffer Selection using Leader key
      vim.keymap.set('n', '<leader>1', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<leader>2', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<leader>3', function()
        harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<leader>4', function()
        harpoon:list():select(4)
      end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-[>', function()
        harpoon:list():prev { ui_nav_wrap = true }
      end, { desc = 'Next harpoon item' })
      vim.keymap.set('n', '<C-]>', function()
        harpoon:list():next { ui_nav_wrap = true }
      end, { desc = 'Prev harpoon item' })
    end,
  },
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {
        keymaps = {
          accept_suggestion = '<C-y>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-j>',
        },
        ignore_filetypes = { cpp = true, rust = true, go = true, asm = true, nix = true },
        color = {
          suggestion_color = '#ffffff',
          cterm = 244,
        },
        log_level = 'info', -- set to "off" to disable logging completely
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false, -- disables built in keymaps for more manual control
        condition = function()
          return false
        end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
      }
    end,
  },
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1

      -- vim.g.vimtex_compiler_silent = 1
      vim.g.vimtex_quickfix_enabled = 0
    end,
  },

  {
    'drippypal/nvim-rtl',
    dir = vim.fn.stdpath 'config' .. '/lua/nvim-rtl',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    config = function()
      require('nvim-rtl').setup()
    end,
  },

  {
    'b0o/SchemaStore.nvim',
    lazy = true,
    version = false, -- last release is way too old
  },

  -- {
  --   'yetone/avante.nvim',
  --   event = 'VeryLazy',
  --   lazy = false,
  --   version = false, -- set this if you want to always pull the latest change
  --   opts = {
  --     ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  --     provider = 'copilot', -- Recommend using Claude
  --     auto_suggestions_provider = 'copilot', -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
  --     -- claude = {
  --     --   endpoint = 'https://api.anthropic.com',
  --     --   model = 'claude-3-5-sonnet-20241022',
  --     --   temperature = 0,
  --     --   max_tokens = 4096,
  --     -- },
  --     ---Specify the special dual_boost mode
  --     ---1. enabled: Whether to enable dual_boost mode. Default to false.
  --     ---2. first_provider: The first provider to generate response. Default to "openai".
  --     ---3. second_provider: The second provider to generate response. Default to "claude".
  --     ---4. prompt: The prompt to generate response based on the two reference outputs.
  --     ---5. timeout: Timeout in milliseconds. Default to 60000.
  --     ---How it works:
  --     --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
  --     ---Note: This is an experimental feature and may not work as expected.
  --     -- dual_boost = {
  --     --   enabled = false,
  --     --   first_provider = 'openai',
  --     --   second_provider = 'claude',
  --     --   prompt = 'Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]',
  --     --   timeout = 60000, -- Timeout in milliseconds
  --     -- },
  --     -- behaviour = {
  --     --   auto_suggestions = false, -- Experimental stage
  --     --   auto_set_highlight_group = true,
  --     --   auto_set_keymaps = true,
  --     --   auto_apply_diff_after_generation = false,
  --     --   support_paste_from_clipboard = false,
  --     --   minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
  --     -- },
  --     -- mappings = {
  --     --   --- @class AvanteConflictMappings
  --     --   diff = {
  --     --     ours = 'co',
  --     --     theirs = 'ct',
  --     --     all_theirs = 'ca',
  --     --     both = 'cb',
  --     --     cursor = 'cc',
  --     --     next = ']x',
  --     --     prev = '[x',
  --     --   },
  --     --   suggestion = {
  --     --     accept = '<M-l>',
  --     --     next = '<M-]>',
  --     --     prev = '<M-[>',
  --     --     dismiss = '<C-]>',
  --     --   },
  --     --   jump = {
  --     --     next = ']]',
  --     --     prev = '[[',
  --     --   },
  --     --   submit = {
  --     --     normal = '<CR>',
  --     --     insert = '<C-s>',
  --     --   },
  --     --   sidebar = {
  --     --     apply_all = 'A',
  --     --     apply_cursor = 'a',
  --     --     switch_windows = '<Tab>',
  --     --     reverse_switch_windows = '<S-Tab>',
  --     --   },
  --     -- },
  --     -- hints = { enabled = true },
  --     -- windows = {
  --     --   ---@type "right" | "left" | "top" | "bottom"
  --     --   position = 'right', -- the position of the sidebar
  --     --   wrap = true, -- similar to vim.o.wrap
  --     --   width = 30, -- default % based on available width
  --     --   sidebar_header = {
  --     --     enabled = true, -- true, false to enable/disable the header
  --     --     align = 'center', -- left, center, right for title
  --     --     rounded = true,
  --     --   },
  --     --   input = {
  --     --     prefix = '> ',
  --     --     height = 8, -- Height of the input window in vertical layout
  --     --   },
  --     --   edit = {
  --     --     border = 'rounded',
  --     --     start_insert = true, -- Start insert mode when opening the edit window
  --     --   },
  --     --   ask = {
  --     --     floating = false, -- Open the 'AvanteAsk' prompt in a floating window
  --     --     start_insert = true, -- Start insert mode when opening the ask window
  --     --     border = 'rounded',
  --     --     ---@type "ours" | "theirs"
  --     --     focus_on_apply = 'ours', -- which diff to focus after applying
  --     --   },
  --     -- },
  --     -- highlights = {
  --     --   ---@type AvanteConflictHighlights
  --     --   diff = {
  --     --     current = 'DiffText',
  --     --     incoming = 'DiffAdd',
  --     --   },
  --     -- },
  --     -- --- @class AvanteConflictUserConfig
  --     -- diff = {
  --     --   autojump = true,
  --     --   ---@type string | fun(): any
  --     --   list_opener = 'copen',
  --     --   --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
  --     --   --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
  --     --   --- Disable by setting to -1.
  --     --   override_timeoutlen = 500,
  --     -- },
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = 'make',
  --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  --   dependencies = {
  --     'stevearc/dressing.nvim',
  --     'nvim-lua/plenary.nvim',
  --     'MunifTanjim/nui.nvim',
  --     --- The below dependencies are optional,
  --     'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
  --     'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
  --     {
  --       'zbirenbaum/copilot.lua', -- for providers='copilot'
  --       opts = {},
  --     },
  --     {
  --       -- support for image pasting
  --       'HakonHarnes/img-clip.nvim',
  --       event = 'VeryLazy',
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       'MeanderingProgrammer/render-markdown.nvim',
  --       opts = {
  --         file_types = { 'markdown', 'Avante' },
  --       },
  --       ft = { 'markdown', 'Avante' },
  --     },
  --   },
  -- },
  {
    -- Maintained fork of the (abandoned) ahmedkhalf/project.nvim.
    -- Fixes the `vim.lsp.buf_get_clients()` removal in Nvim 0.12.
    -- Note: the module was renamed `project_nvim` -> `project`.
    'DrKJeff16/project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('project').setup {
        patterns = { '.git', 'Makefile', 'package.json', 'go.mod', 'Cargo.toml' },
        silent_chdir = true,
      }
      require('telescope').load_extension 'projects'
    end,
  },

  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',
    },
    opts = {
      workspaces = {
        {
          name = 'My Obsidian Vault',
          path = vim.env.OBSIDIAN_VAULT
            or (vim.fn.has 'mac' == 1 and vim.fn.expand '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main-Vault' or vim.fn.expand '~/Documents/Main-Vault'),
        },
      },
      templates = {
        folder = '5. Helpers/a. Templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
    },
  },

  {
    'glepnir/template.nvim',
    cmd = { 'Template', 'TemProject' },
    config = function()
      require('template').setup {
        temp_dir = '~/.config/nvim/templates',
      }
    end,
  },
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {},
  -- },
  -- {
  --   'chentoast/marks.nvim',
  --   event = 'VeryLazy',
  --   opts = {
  --     -- whether to map keybinds or not. default true
  --     default_mappings = true,
  --     -- which builtin marks to show. default {}
  --     builtin_marks = { '.', '<', '>', '^' },
  --     -- whether movements cycle back to the beginning/end of buffer. default true
  --     cyclic = true,
  --     -- whether the shada file is updated after modifying uppercase marks. default false
  --     force_write_shada = false,
  --     -- how often (in ms) to redraw signs/recompute mark positions.
  --     -- higher values will have better performance but may cause visual lag,
  --     -- while lower values may cause performance penalties. default 150.
  --     refresh_interval = 250,
  --     -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
  --     -- marks, and bookmarks.
  --     -- can be either a table with all/none of the keys, or a single number, in which case
  --     -- the priority applies to all marks.
  --     -- default 10.
  --     sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
  --     -- disables mark tracking for specific filetypes. default {}
  --     excluded_filetypes = {},
  --     -- disables mark tracking for specific buftypes. default {}
  --     excluded_buftypes = {},
  --     -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
  --     -- sign/virttext. Bookmarks can be used to group together positions and quickly move
  --     -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
  --     -- default virt_text is "".
  --     -- bookmark_0 = {
  --     --   sign = '⚑',
  --     --   virt_text = 'hello world',
  --     --   -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
  --     --   -- defaults to false.
  --     --   annotate = false,
  --     -- },
  --     mappings = {},
  --   },
  -- },
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        '<leader>n',
        function()
          local path = vim.fn.expand '%:p'
          if vim.startswith(path, 'oil://') then
            path = require('oil').get_current_dir() or vim.fn.getcwd()
          end
          require('yazi').yazi(nil, path)
        end,
        desc = 'Open yazi at the current file',
      },
      {
        -- Open in the current working directory
        '<leader>y',
        '<cmd>Yazi cwd<cr>',
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        '<c-up>',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
      yazi_floating_window_border = 'none',
    },
  },
}
