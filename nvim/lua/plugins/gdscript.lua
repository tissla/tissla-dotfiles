return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")
      local util = require("lspconfig.util")

      if not configs.gdscript then
        configs.gdscript = {
          default_config = {
            name = "gdscript",
            cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
            filetypes = { "gdscript" },
            root_dir = util.root_pattern("project.godot", ".git"),
          },
        }
      end

      opts.servers = opts.servers or {}
      opts.servers.gdscript = {}
    end,
  },
}
