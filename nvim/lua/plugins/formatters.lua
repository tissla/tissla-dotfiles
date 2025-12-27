return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
  opts = {
    notify_on_error = false,
    formatters_by_ft = {
      python = { "black" },
      qml = { "qmlformat" },
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
    },
  },
}
