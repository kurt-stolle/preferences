-- vim: ts=2 sts=2 sw=2 et

-- External tools required
-- Windows Terminal + pwsh
-- mingw64 toolchain: https://www.msys2.org/
-- ripgrep: https://github.com/BurntSushi/ripgrep
-- win32yank for clipboard integration
-- sharkdp/fd

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local opt = vim.opt

opt.background = "dark"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.termencoding = "utf-8"

opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.mouse = "a"

opt.autowrite = true
opt.confirm = true
opt.inccommand = "nosplit"
opt.laststatus = 0
opt.list = true

opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.wrap = true
opt.colorcolumn = "89"

opt.splitbelow = true
opt.splitright = true

opt.scrolloff = 4
opt.sidescrolloff = 8
opt.winminwidth = 5

opt.expandtab = true
opt.shiftwidth = 4
opt.shiftround = true
opt.tabstop = 4

opt.showmode = false
opt.signcolumn = "yes"
opt.termguicolors = true
opt.hidden = true

opt.undofile = true
opt.undolevels = 10000

opt.secure = true
opt.exrc = true

-- set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- terminal settings
if vim.fn.executable "pwsh" == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
elseif vim.fn.executable "zsh" == 1 then
  vim.opt.shell = "zsh"
  vim.opt.shellcmdflag = "-c"
  vim.opt.shellredir = "2>&1 > %s"
  vim.opt.shellpipe = "2>&1 | tee %s > /dev/null; exit ${PIPESTATUS[0]}"
  vim.opt.shellquote = "'"
  vim.opt.shellxquote = ""
elseif vim.fn.executable "bash" == 1 then
  vim.opt.shell = "bash"
  vim.opt.shellcmdflag = "-c"
  vim.opt.shellredir = "2>&1 > %s"
  vim.opt.shellpipe = "2>&1 | tee %s > /dev/null; exit ${PIPESTATUS[0]}"
  vim.opt.shellquote = "'"
  vim.opt.shellxquote = ""
end

vim.keymap.set('t', '<Esc>', "<C-\\><C-n>")
vim.keymap.set('t', '<C-w>', "<C-\\><C-n><C-w>")

-- minimize terminal split
vim.keymap.set('n', '<C-g>', "3<C-w>_")

-- plugins
require("lazy").setup({
  -- theme
  -- { "catppuccin/nvim", lazy = true, name = "catppuccin", priority=1000 },
  { "arzg/vim-colors-xcode",       lazy = true, name = "xcode", priority = 1000 },

  -- devicons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Nvim tree
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup()
    end
  },

  -- cheatsheet
  { "sudormrfbin/cheatsheet.nvim", lazy = false, event = "BufWinEnter", config = function() require("cheatsheet").setup() end },


  -- Copilot
  { "github/copilot.vim",          lazy = false, priority = 999 },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    event = "VeryLazy",
    config = function()
      require("luasnip.loaders.from_lua").load({ paths = "./snippets" })
    end
  },

  -- mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "black")
    end,
  },

  -- none-ls
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.black)
    end,
  },

  -- language server protocol
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local mason = require('mason')
      mason.setup()

      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = { "pyright", "lua_ls" },
        automatic_installation = true,
      }

      local lspconfig = require("lspconfig")
      lspconfig.pyright.setup {
        capabilities = capabilities,
      }
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
      }
    end
  },

  -- latex
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_options = "go here"

      if vim.fn.executable "zathura" == 1 then
        vim.g.vimtex_view_method = "zathura"
      elseif vim.fn.executable "sioyek" == 1 then
        vim.g.vimtex_view_method = "sioyek"
      elseif vim.fn.executable "sioyek.exe" == 1 then
        vim.g.vimtex_view_method = "sioyek.exe"
      end
    end
  },

  -- autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    },
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end
        },
        completion = {
          --autocomplete = true
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<c-cr>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<c-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }
      })
    end
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-n>",
            node_incremental = "<C-n>",
            scope_incremental = "<C-s>",
            node_decremental = "<C-m>",
          }
        }
      })
    end
  },

  -- debugger
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- fancy UI for the debugger
      {
        "rcarriga/nvim-dap-ui",
        -- stylua: ignore
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
          { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
        },
        opts = {},
        config = function(_, opts)
          -- setup dap config by VsCode launch.json file
          -- require("dap.ext.vscode").load_launchjs()
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
      },

      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      -- which key integration
      {
        "folke/which-key.nvim",
        opts = {
          defaults = {
            ["<leader>d"] = { name = "+debug" },
          },
        },
      },
      -- mason.nvim integration
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_installation = true,
          handlers = {},
          ensure_installed = {
            -- Update this to ensure that you have the debuggers for the langs you want
          },
        },
      },
    },
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to line (no execute)" },
      { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
      { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
    },
    config = function()
    end,
  },

  -- fuzzy find
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>sf",      "<cmd>Telescope git_files<cr>",                     desc = "Find Files (root dir)" },
      { "<leader><space>", "<cmd>Telescope buffers<cr>",                       desc = "Find Buffers" },
      { "<leader>sg",      "<cmd>Telescope live_grep<cr>",                     desc = "Search Project" },
      { "<leader>ss",      "<cmd>Telescope lsp_document_symbols<cr>",          desc = "Search Document Symbols" },
      { "<leader>sw",      "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Search Workspace Symbols" },
    },
    opts = {
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case"
        }
      }
    }
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require('telescope').load_extension('fzf')
    end
  },

  -- linting + formatting
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.diagnostics.ruff,
          null_ls.builtins.formatting.black,
        }
      })
    end
  },

  -- terminal
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    version = "*",
    opts = {
      size = 20,
      open_mapping = "<c-s>", -- s for shell
    }
  },

  -- status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = true,
        theme = 'onedark',
        conponent_separators = '|',
        section_separators = '',
      }
    },
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    version = "v3.*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",            desc = "Toggle Buffer Pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close Unpinned Buffers" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        numbers = "buffer_id",
        always_show_bufferline = false
      }
    }
  },

  -- auto pairing
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    config = function(_, opts)
      require('mini.pairs').setup(opts)
    end
  },

  -- surround text object
  {
    "echasnovski/mini.surround",
    config = function(_, opts)
      require('mini.surround').setup(opts)
    end
  },

  -- show indent guides on blank lines
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
})

-- set colour scheme
vim.cmd.colorscheme "xcode"

-- up / down with line wrap
vim.keymap.set('n', '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- highlight yanked text
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- lsp keybindings
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename Symbol' })
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
vim.keymap.set('n', '<leader>ff', vim.lsp.buf.format, { desc = 'Format Code' })
