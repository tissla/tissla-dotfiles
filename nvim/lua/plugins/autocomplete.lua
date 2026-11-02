return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      list = {
        selection = {
          auto_insert = false,
        },
      },
    },
    keymap = {
      preset = "default",
      ["<CR>"] = { "fallback" },
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
    },
    cmdline = {
      sources = function()
        local type = vim.fn.getcmdtype()
        if type == ":" then
          return { "cmdline", "path" }
        elseif type == "/" or type == "?" then
          return { "buffer" }
        end
        return {}
      end,
    },
  },
}
