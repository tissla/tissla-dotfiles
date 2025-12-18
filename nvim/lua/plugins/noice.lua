return {
  "folke/noice.nvim",
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    messages = { enabled = true },
    presets = {
      command_palette = true,
      bottom_search = false,
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)

    vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { bg = "#1e1b29", fg = "#9ca3af" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#ff9e64" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#1e1b29", fg = "#c9c7d4" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#8b5cf6" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = "#8b5cf6" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "SnacksPickerInputSearch", { fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "CurSearch", { fg = "#1e1b29", bg = "#ff9e64", bold = true })
    vim.api.nvim_set_hl(0, "Search", { fg = "#8b5cf6", bg = "#ff9e64", bold = true })
    vim.api.nvim_set_hl(0, "SearchCount", { fg = "#1e1b29", bold = true })
    vim.api.nvim_set_hl(0, "Pmenu", { bg = "#2b263b", fg = "#c9c7d4" })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#1e1b29" })
  end,
}
