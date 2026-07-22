return {
  "saghen/blink.cmp",
  opts = {
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
