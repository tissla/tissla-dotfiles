return {
  {
    "folke/zen-mode.nvim",
    opts = {
      window = { width = 80 },
      on_open = function()
        vim.g._writer_mode = true
        vim.api.nvim_set_hl(0, "Normal", { fg = "#569CD5", bg = "#181825" })
        vim.api.nvim_set_hl(0, "NormalNC", { fg = "#b8b6c3" })
        vim.api.nvim_set_hl(0, "SignColumn", { fg = "#b8b6c3", bg = "#1e1b29" })

        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en_us", "sv" }
      end,

      on_close = function()
        vim.g._writer_mode = false

        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
        vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

        -- Spell av (om du vill)
        vim.opt_local.spell = false
      end,
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
  },
}
