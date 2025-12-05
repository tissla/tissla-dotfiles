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

  -- neotree
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
        window = {
          width = 32,
        },
        close_if_last_window = true,
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
    end,
  },

  -- theme
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

      -- normal line numbering
      vim.opt.number = true
      vim.opt.relativenumber = false

      -- transparent background
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

      -- cursorline clr
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#41395e" })

      -- vim.api.nvim_set_hl(0, "Comment", { fg = "#6a9955", italic = true, bold = false })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7280", bg = "none" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bg = "none", bold = true })

      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

      -- neotree if used
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#ff9e64" })

      -- Snacks side explorer tree
      vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "none", default = false })

      vim.api.nvim_set_hl(0, "SnacksPickerTree", { bg = "none" })

      vim.api.nvim_set_hl(0, "SnacksBackdrop", { bg = "none" })

      -- top of tree
      vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "none" })

      vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { bg = "none" })

      vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { bg = "none" })
      -- background var
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },

  -- installs
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = function()
      --   vim.cmd([[colorscheme tokyonight]])
      --   vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      -- end,
      mason = {
        ensure_installed = {
          "stylua",
          "shellcheck",
          "shfmt",
          "flake8",

          -- added
          "qmlformat",
          "prettier",
          "rustfmt",
          "clang-format",
          "goimports",
          "gofmt",

          --lsp
          "qmlls",
          "rust_analyzer",
          "lua_ls",
          "clangd",
        },
      },
    },
  },
}
