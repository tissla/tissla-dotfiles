return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("qml", {
        name = "qml-language-server",
        cmd = { "/home/tissla/.local/bin/qml-language-server" },
        filetypes = { "qml" },
        root_markers = { ".qmlproject", "qmldir", "CMakeLists.txt" },
        settings = {},
      })

      vim.lsp.enable("qml")
    end,
  },
}
