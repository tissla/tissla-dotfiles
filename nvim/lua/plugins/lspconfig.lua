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
                pyflakes = { enabled = false },
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
        -- QML
        qmlls = {
          cmd = { "qmlls6", "-E" },
          cmd_env = {
            QMLLS_BUILD_DIRS = "/usr/lib/qt6/qml",
            QML_IMPORT_PATH = table.concat({
              "/usr/lib/qt6/qml",
              vim.fn.expand("~/.config/quickshell"),
            }, ":"),
            QML2_IMPORT_PATH = "/usr/lib/qt6/qml",
          },
        },
      },
    },
  },
}
