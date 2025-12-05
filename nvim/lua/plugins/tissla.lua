return {

  -- disabled stuff
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      picker = {
        sources = {
          files = { enabled = false },
          file_browser = false,
        },
      },
    },
  },

  -- noice
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
        },
        messages = { enabled = true },
        presets = {
          command_palette = true,
        },
      })

      vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { bg = "#1e1b29", fg = "#9ca3af" })

      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#ff9e64" })

      vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#1e1b29", fg = "#c9c7d4" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#8b5cf6" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = "#8b5cf6" })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#f9e2af", bold = true })
    end,
  },

  -- neotree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "mason-org/mason.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = { width = 32 },
        close_if_last_window = true,
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
        },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
    end,
  },

  -- colorscheme
  {
    "gmr458/vscode_modern_theme.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vscode_modern").setup({
        theme = "dark",
        cursorline = true,
        transparent_background = true,
      })
      vim.cmd.colorscheme("vscode_modern")
      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#41395e" })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7280", bg = "none" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bg = "none", bold = true })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#ff9e64" })
      vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "none", default = false })
      vim.api.nvim_set_hl(0, "SnacksPickerTree", { bg = "none" })
      vim.api.nvim_set_hl(0, "SnacksBackdrop", { bg = "none" })
      vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "none" })
      vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { bg = "none" })
      vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },

  -- mason autosetup
  "mason-org/mason-lspconfig.nvim",
  opts = {},
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },
        qmlls = {
          cmd = { "qmlls6", "-E" },
          cmd_env = {
            qmlls_build_dirs = "/usr/lib/qt6/qml",
            qml_import_path = table.concat({
              "/usr/lib/qt6/qml",
              vim.fn.expand("~/.config/quickshell"),
            }, ":"),
            qml2_import_path = "/usr/lib/qt6/qml",
          },
        },
      },
    },
  },

  -- conform formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        go = { "goimports", "gofmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        qml = { "qmlformat" },
      },
    },
  },

  -- go setup
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua" },
    config = function()
      require("go").setup()
    end,
    ft = { "go" },
  },
}
