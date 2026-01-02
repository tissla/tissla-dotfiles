return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-cmdline",
  },
  opts = function(_, opts)
    local cmp = require("cmp")

    opts.mapping = opts.mapping or {}
    opts.mapping["<C-Space>"] = cmp.mapping.complete()

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
    })

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
        { name = "spell" },
      },
    })

    opts.sources = cmp.config.sources({
      { name = "spell" },
      { name = "buffer" },
    })
  end,
}
