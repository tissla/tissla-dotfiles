-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us", "sv" }
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.textwidth = 0
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  callback = function()
    if vim.bo.filetype == "" then
      vim.bo.filetype = "dosini"
    end
  end,
})
