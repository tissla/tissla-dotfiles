return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                pyflakes = { enabled = true },
              },
            },
          },
        },
        -- C/C++
        clangd = {
          cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
          },
        },
        -- Rust
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              checkOnSave = { command = "clippy" },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              usePlaceholders = true,
              completeUnimported = true,

              analyses = {
                unusedparams = true,
                unusedwrite = true,
                nilness = true,
                shadow = true,
              },
            },
          },
        },
        -- QML
        qml = {
          name = "qml-language-server",
          cmd = { "/home/tissla/.local/bin/qml-language-server" },
          filetypes = { "qml" },
          root_markers = { ".qmlproject", "qmldir", "CMakeLists.txt" },
          settings = {},
        },
        -- qmlls = {
        --   cmd = { "qmlls6", "-E" },
        --   cmd_env = {
        --     QMLLS_BUILD_DIRS = "/usr/lib/qt6/qml",
        --     QML_IMPORT_PATH = table.concat({
        --       "/usr/lib/qt6/qml",
        --       vim.fn.expand("~/.config/quickshell"),
        --     }, ":"),
        --     QML2_IMPORT_PATH = "/usr/lib/qt6/qml",
        --   },
        -- },
        -- ltex
        ltex = {
          filetypes = { "markdown", "text", "tex" },
          settings = {
            ltex = {
              language = "en-US",
              enabled = { "en-US", "sv-SE" },
              additionalRules = {
                motherTongue = "en",
              },
            },
          },
        },
        -- arduino
        arduino_language_server = {
          cmd = {
            "arduino-language-server",
            "-cli",
            "arduino-cli",
            "-cli-config",
            vim.fn.expand("~/.arduino15/arduino-cli.yaml"),
            "-fqbn",
            "arduino:zephyr:unoq",
          },
          filetypes = { "arduino" },
        },
      },
      setup = {
        gdscript = function(_, opts)
          require("lspconfig").gdscript.setup({
            cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
            filetypes = { "gd" },
            root_dir = require("lspconfig.util").root_pattern("project.godot", ".git"),
          })
          return true
        end,
      },
    },
  },
}
