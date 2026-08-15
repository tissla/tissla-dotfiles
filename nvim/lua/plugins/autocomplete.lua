return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      presets = "default",
      ["<CR>"] = { "fallback" },
      ["<Tab"] = { "accept", "fallback" },
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
