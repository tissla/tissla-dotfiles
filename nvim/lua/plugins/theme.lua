return {
  "gmr458/vscode_modern_theme.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("vscode_modern").setup({
      theme = "dark",
      cursorline = true,
      transparent_background = true,
    })
    vim.cmd.colorscheme("vscode_modern")
    vim.opt.number = true
    vim.opt.relativenumber = false
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#41395e" })
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7280", bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bg = "none", bold = true })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#ff9e64" })
    vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "none", default = false })
    vim.api.nvim_set_hl(0, "SnacksPickerTree", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksBackdrop", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerInput", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { bg = "none" })
    vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    -- additional
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

    -- specific to csharp
    vim.api.nvim_set_hl(0, "@lsp.type.class.cs", { link = "Type" })

    vim.api.nvim_set_hl(0, "@lsp.type.interface.cs", { link = "Type" })
    vim.api.nvim_set_hl(0, "@lsp.type.struct.cs", { link = "Type" })
    vim.api.nvim_set_hl(0, "@lsp.type.enum.cs", { link = "Type" })

    vim.api.nvim_set_hl(0, "@lsp.type.fieldName.cs", { link = "Variable" })

    vim.api.nvim_set_hl(0, "@lsp.type.extensionMethodName.cs", { link = "Function" })
  end,
}
