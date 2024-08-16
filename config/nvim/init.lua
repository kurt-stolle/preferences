-- vim: ts=2 sts=2 sw=2 et
--
local opt = vim.opt
local env = vim.env
local keymap = vim.keymap

-- utilities
local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

-- cached plugin loader
vim.loader.enable()

-- lazy initialization
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
opt.rtp:prepend(env.LAZY or lazypath)

-- common settings
opt.background = vim.env.THEME_COLOR or "dark"
opt.termguicolors = true
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.breakindent = true

-- providers
vim.g.python3_host_prog = vim.loop.os_homedir() .. "/.venvs/nvim/bin/python3"
vim.g.node_host_prog = vim.loop.os_homedir() .. '/.local/bin/nvim-node'

-- clipboard
-- this is handled by a plugin instead
-- vim.g.clipboard = "unnamedplus"
--[[vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ["+"] = require('vim.ui.clipboard.osc52').copy,
    ["*"] = require('vim.ui.clipboard.osc52').copy,
  },
  paste = {
    ["+"] = require('vim.ui.clipboard.osc52').paste,
    ["*"] = require('vim.ui.clipboard.osc52').paste,
  },
}
]]

-- autocomplete action
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
opt.hidden = true

opt.undofile = true
opt.undolevels = 10000

opt.updatetime = 100 --200

opt.secure = true
opt.exrc = true

-- disable netrw, we use `neo-tree` instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- terminal settings
opt.shell = vim.env.SHELL or (vim.fn.executable "pwsh" == 1 and "pwsh") or (vim.fn.executable "bash" == 1 and "bash") or
    (vim.fn.executable "ash" == 1 and "ash") or "sh"
if opt.shell == "pwsh" then
  -- PowerShell
  opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
else
  -- Default to a POSIX shell
  opt.shellcmdflag = "-c"
  opt.shellredir = "2>&1 > %s"
  opt.shellpipe = "2>&1 | tee %s > /dev/null; exit ${PIPESTATUS[0]}"
  opt.shellquote = "'"
  opt.shellxquote = ""
end

keymap.set('t', '<Esc>', "<C-\\><C-n>")
keymap.set('t', '<C-w>', "<C-\\><C-n><C-w>")

-- plugins
-- using the lazy.nvim plugin manager
-- this takes over the default plugin manager
-- https://www.lazyvim.org/
require("lazy").setup({
  rocks = {
    hererocks = true,
  },
  spec = {
    -- clipboard (OSC52 support)
    -- https://github.com/ibhagwan/smartyank.nvim?tab=readme-ov-file#what-is-smartyank
    --{ 'ibhagwan/smartyank.nvim',    lazy = false },
    -- themes
    {
      "catppuccin/nvim",
      lazy = true,
      priority = 1000,
      name = "catppuccin",
      config = function()
        require("catppuccin").setup({
          color_overrides = {
            mocha = {
              --base = "#000000"
            }
          },
          integrations = {
            mason = true,
          },
        })
      end,
      init = function()
        vim.cmd.colorscheme "catppuccin"
      end,
    },
    -- { "arzg/vim-colors-xcode",      lazy = true, priority = 1000, name = "xcode" },
    -- nvim-tree
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = false,
          popup_border_style = "rounded",
          enable_git_status = true,
          enable_diagnostics = false,
        })
      end,
      init = function()
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
              require("neo-tree.command").execute({ toggle = true })
            end
          end
        })
      end,
      keys = {
        { "nt", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
        { "nr", "<cmd>Neotree reveal<cr>", desc = "Reveal file in Neo-tree" },
        { "nf", "<cmd>Neotree reveal<cr>", desc = "Find File in Neo-tree" },
      },
    },
    -- Copilot
    {
      "github/copilot.vim",
      priority = 999,
      lazy = false
    },
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
      event = "VeryLazy",
      opts = function(_, opts)
        if not opts.ensure_installed then
          opts.ensure_installed = {}
        end
        --table.insert(opts.ensure_installed, "black")
        --table.insert(opts.ensure_installed, "ruff")
      end,
    },
    -- language server protocol
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
      },
      config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        local mason = require('mason')
        mason.setup()

        local mason_lspconfig = require 'mason-lspconfig'
        mason_lspconfig.setup {
          ensure_installed = { "pyright", "lua_ls", "bashls" },
          automatic_installation = true,
        }

        local lspconfig = require("lspconfig")
        lspconfig.lua_ls.setup {
          capabilities = capabilities,
        }
        lspconfig.bashls.setup {
          capabilities = capabilities,
        }
        lspconfig.pyright.setup {
          capabilities = capabilities,
          settings = {
            -- Using Ruff instead
            disableOrganizeImports = true,
          },
          python = {
            -- Using Ruff instead
            analysis = {
              ignore = { '*' },
            },
          },
        }
        lspconfig.ruff.setup {
          -- https://github.com/astral-sh/ruff/blob/main/crates/ruff_server/docs/setup/NEOVIM.md
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            if client.name == "ruff" then
              -- Disable hover in favor of pyright
              client.server_capabilities.hoverProvider = false
            end
          end
        }
      end
    },
    {
      "kkoomen/vim-doge",
      event = "VeryLazy",
      keys = {
        { "<leader>dg", "<Plug>(doge-generate)", desc = "Generate Documentation" },
      },
      init = function()
        vim.g.doge_doc_standard_python = 'numpy'
        vim.g.doge_enable_mappings = 0
        vim.g.doge_python_settings = {
          single_quotes = 0, omit_redundant_param_types = 1
        }
      end
    },
    -- Keybinding helpers
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
      end,
      opts = {}
    },
    -- Lua LSP configs for nvim
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "luvit-meta/library", words = { "vim%.uv" } },
          { path = "wezterm-types",      mods = { "wezterm" } },
        },
      },
    },
    { "justinsgithub/wezterm-types", lazy = true },
    { "Bilal2453/luvit-meta",        lazy = true },
    -- latex
    {
      "lervag/vimtex",
      ft = "tex",
      init = function()
        vim.g.vimtex_options = "go here" -- ? from docs
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
          },
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            --[[[          ["<c-cr>"] = cmp.mapping(function(fallback)
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
          --]]
            ["<C-space>"] = cmp.mapping(function(fallback)
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
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = {
            { name = "lazydev", group_index = 0 },
            { name = "nvim_lsp" },
            { name = "luasnip" },
          }
        })
      end
    },
    -- treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      version = "*",
      build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
      end,
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
          auto_install = true,
          sync_install = false,
          ignore_install = {},
          highlight = { enable = true, additional_vim_regex_highlighting = true },
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
    {
      "nvim-treesitter/nvim-treesitter-textobjects", version = "*", after = "nvim-treesitter"
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
        --{ "<leader>sf",      "<cmd>Telescope git_files<cr>",                     desc = "Find Files (root dir)" },
        --{"<leader>sf>",    "<cmd>Telescope find_files<cr>",                     desc = "Find Files" },
        -- Use git_files first, if not found, use find_files
        {
          "<leader>sf",
          function()
            if vim.fn.isdirectory(".git") == 1 then
              vim.cmd "Telescope git_files"
            else
              vim.cmd "Telescope find_files"
            end
          end,
          desc = "Find Files"
        },
        { "<leader><space>", "<cmd>Telescope buffers<cr>",                       desc = "Find Buffers" },
        { "<leader>sg",      "<cmd>Telescope live_grep<cr>",                     desc = "Search Project" },
        { "<leader>ss",      "<cmd>Telescope lsp_document_symbols<cr>",          desc = "Search Document Symbols" },
        { "<leader>sw",      "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Search Workspace Symbols" },
        { "<leader>sd",      "<cmd>Telescope diagnostics<cr>",                   desc = "Search Diagnostics" },
        { "<leader>sr",      "<cmd>Telescope registers<cr>",                     desc = "Search Registers" },
        { "<leader>sq",      "<cmd>Telescope quickfix<cr>",                      desc = "Search Quickfix" },
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
      cond = function() return is_windows; end,
      config = function()
        require('telescope').load_extension('fzf')
      end
    },
    -- terminal
    {
      "akinsho/toggleterm.nvim",
      event = "VeryLazy",
      version = "*",
      opts = {
        --size = 20,
        --persist_size = false,   -- always open with the same size
        open_mapping = "<C-s>", -- s for shell
        direction = "float",
      }
    },
    -- status line
    {
      "nvim-lualine/lualine.nvim",
      event = "VeryLazy",
      opts = {
        options = {
          icons_enabled = true,
          theme = opt.background == 'light' and 'onelight' or 'catppuccin',
          conponent_separators = '|',
          section_separators = '',
        }
      },
    },
    -- conda
    {
      "kmontocam/nvim-conda",
      dependencies = { "nvim-lua/plenary.nvim" },
      lazy = false,
      version = "*",
      cond = function()
        return vim.fn.executable "conda" == 1
      end,
    },
    -- hydra
    {
      "anuvyklack/hydra.nvim",
      event = "VeryLazy",
      version = "*",
    },
    -- auto pairing
    --{
    --  "echasnovski/mini.pairs",
    --  event = "VeryLazy",
    --  config = function(_, opts)
    --    require('mini.pairs').setup(opts)
    --  end
    --},
    -- mini.surround
    {
      "echasnovski/mini.surround",
      event = "VeryLazy",
    },
    -- mini.ai
    {
      "echasnovski/mini.ai",
      event = "VeryLazy",
      dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
      opts = function()
        local nn = require "notebook-navigator"
        return { custom_textobjects = { h = nn.miniai_spec } }
      end,
    },
    -- mini.hipatterns
    {
      "echasnovski/mini.hipatterns",
      event = "VeryLazy",
      dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
      opts = function()
        -- Notebook navigator cell pattern
        local nn = require "notebook-navigator"
        return { highlighters = { cells = nn.minihipatterns_spec } }
      end,
    },
    -- wezterm
    -- https://github.com/willothy/wezterm.nvim
    {
      'willothy/wezterm.nvim',
      config = true,
      cond = function()
        return vim.fn.executable "wezterm" == 1
      end,
    },
    -- images
    -- https://github.com/3rd/image.nvim
    -- https://github.com/jstkdng/ueberzugpp
    {
      "3rd/image.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "leafo/magick" },
      cond = function()
        return vim.fn.executable "magick" == 1 and ~is_windows
      end,
      config = function()
        require("image").setup({
          backend = "kitty",
          max_width = 100,
          max_height = 12,
          max_height_window_percentage = math.huge,
          max_width_window_percentage = math.huge,
          window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
          window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        })
      end
    },
    -- notebook navigator
    --[[{
      "GCBallesteros/NotebookNavigator.nvim",
      keys = {
        { "]h",        function() require("notebook-navigator").move_cell "d" end },
        { "[h",        function() require("notebook-navigator").move_cell "u" end },
        { "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
        { "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
      },
      dependencies = {
        "echasnovski/mini.comment",
        "echasnovski/mini.ai",
        "echasnovski/mini.hipatterns",
        -- "hkupty/iron.nvim", -- repl provider
        -- "akinsho/toggleterm.nvim", -- alternative repl provider
        "benlubas/molten-nvim", -- alnernative repl provider
        "anuvyklack/hydra.nvim",
      },
      event = "VeryLazy",
      config = function()
        local nn = require "notebook-navigator"
        nn.setup({
          activate_hydra_keys = "<leader>h",
          show_hydra_hint = true,
          repl_provider = "molten",
          cell_markers = {
            python = "# %%",
          },
        })
      end,
    },]]
    -- molten (interactive repl)
    -- https://github.com/benlubas/molten-nvim/blob/main/docs/Probably-Too-Quick-Start-Guide.md
    {
      "benlubas/molten-nvim",
      dependencies = { "nvim-lua/plenary.nvim", "3rd/image.nvim" },
      version = "*", -- use version <2.0.0 to avoid breaking changes
      build = ":UpdateRemotePlugins",
      init = function()
        vim.g.molten_output_win_max_height = 12
      end,
      keys = {
        { "<localleader>mi",  "<cmd>MoltenInit<CR>",                  desc = "Initialize Molten.nvim" },
        { "<localleader>me",  "<cmd>MoltenEvaluateOperator<CR>",      desc = "run operator selection",    mode = { "v" } },
        { "<localleader>mrl", "<cmd>MoltenEvaluateLine<CR>",          desc = "evaluate line" },
        { "<localleader>mrr", "<cmd>MoltenReevaluateCell<CR>",        desc = "re-evaluate cell" },
        { "<localleader>mr",  "<cmd><C-u>MoltenEvaluateVisual<CR>gv", desc = "evaluate visual selection", mode = { "v" } },
        { "<localleader>mo",  "<cmd>MoltenEnterOutput<CR>",           desc = "enter output window" },
        { "<localleader>mh",  "<cmd>MoltenHideOutput<CR>",            desc = "hide output window" },
      }
    },
    --[[ bufferline
    {
      "akinsho/bufferline.nvim",
      version = "*",
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
          always_show_bufferline = true
        }
      }
    },]]
    -- show indent guides on blank lines
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
    -- tmux
    --[[{
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup {
        copy_sync = {
          enable = true,
          sync_clipboard = false,
          sync_registers = true,
        },
        resize = {
          enable_default_keybindings = false,
        },
      }
    end,
  },]]
    {
      "mbbill/undotree",
      keys = {
        { "<leader>tt", function() vim.cmd.UndotreeToggle() end, desc = "Toggle Undotree" },
        { "<leader>tf", function() vim.cmd.UndotreeFocus() end,  desc = "Focus Undotree" },
      },
    },
    -- Refactoring plugin (experimental)
    {
      "ThePrimeagen/refactoring.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
      },
    },
  },
})


-- up / down with line wrap
--keymap.set('n', '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
--keymap.set('n', '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

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
--"leader
keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename Symbol' })
keymap.set('n', '<leader>rr', vim.lsp.buf.references, { desc = 'Rename Symbol' })
keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
keymap.set({ 'n', 'i' }, '<C-Q>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
keymap.set({ 'n', 'i' }, '<C-P>', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
keymap.set('n', '<leader>ff', vim.lsp.buf.format, { desc = 'Format Code' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.supports_method('textDocument/implementation') then
      -- Create a keymap for vim.lsp.buf.implementation
    end
    if client.supports_method('textDocument/completion') and vim.lsp.completion then
      -- Enable auto-completion
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    if client.supports_method('textDocument/formatting') then
      -- Format the current buffer on save
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
        end,
      })
    end
  end,
})
