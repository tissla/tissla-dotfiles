--[[
████████╗██╗███████╗███████╗██╗      █████╗ 
╚══██╔══╝██║██╔════╝██╔════╝██║     ██╔══██╗
   ██║   ██║███████╗███████╗██║     ███████║
   ██║   ██║╚════██║╚════██║██║     ██╔══██║
   ██║   ██║███████║███████║███████╗██║  ██║
   ╚═╝   ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
--]]

-- custom nvim config
-- based off kickstart

-- tabstops
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.g.have_nerd_font = true

-- [[ Setting options ]]
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.clipboard = "unnamedplus"

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Install lazy ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
	-- Guess indent
	"NMAC427/guess-indent.nvim",

	-- autocomplete
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
		},
	},

	-- snacks
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			indent = {
				enabled = true,
				char = "│",
			},
			scope = {
				enabled = true,
				char = "│",
			},
		},
	},
	-- Web dev icons
	{
		"nvim-tree/nvim-web-devicons",
		lazy = false,
		priority = 1000,
		config = function()
			require("nvim-web-devicons").setup({ default = true, strict = true })
		end,
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("neogen").setup({
				enabled = true,
				languages = {
					cpp = { template = { annotation_convention = "doxygen" } },
					c = { template = { annotation_convention = "doxygen" } },
				},
			})
		end,
		keys = {
			{
				"<leader>nf",
				function()
					require("neogen").generate()
				end,
				desc = "Generate [N]eogen [F]unction doc",
			},
		},
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			background_colour = "#41395e",
		},
	},

	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				cmdline = {
					enabled = true,
					view = "cmdline_popup",
				},
				messages = { enabled = true },
				presets = {
					command_palette = true,
				},
			})

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
	},

	-- mason autosetup
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{ "mason-org/mason-lspconfig.nvim" },

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
		},
		config = function()
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			local servers = {

				lua_ls = {
					cmd = { "/usr/bin/lua-language-server" },
				},

				-- C/C++
				clangd = {
					cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
					init_options = {
						clangdFileStatus = true,
						usePlaceholders = true,
					},
				},
				-- Rust analyzer
				rust_analyzer = {
					cmd = { "rust-analyzer" },
					settings = {
						["rust-analyzer"] = {
							cargo = { allFeatures = true },
							procMacro = { enable = true },
							checkOnSave = { command = "clippy" },
						},
					},
				},
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			require("mason-lspconfig").setup({
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			-- qmlls setup

			local lspconfig = require("lspconfig")

			lspconfig.qmlls.setup({
				cmd = { "qmlls6", "-E" },
				cmd_env = {
					QMLLS_BUILD_DIRS = "/usr/lib/qt6/qml",
					QML_IMPORT_PATH = table.concat({
						"/usr/lib/qt6/qml",
						vim.fn.expand("~/.config/quickshell"),
					}, ":"),
					QML2_IMPORT_PATH = "/usr/lib/qt6/qml",
				},
				capabilities = capabilities,
			})
		end,
	},

	-- Conform
	{
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
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
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
	},

	-- Colorscheme
	{
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
		end,
	},

	-- Todo comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Mini.nvim
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.comment").setup()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"diff",
				"html",
				"go",
				"rust",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},

	-- Go.nvim
	{
		"ray-x/go.nvim",
		dependencies = { "ray-x/guihua.lua" },
		config = function()
			require("go").setup()
		end,
		ft = { "go" },
	},

	-- File Explorer (neo-tree)
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer NeoTree" },
			{ "<leader>fe", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
		},
	},
})

-- autocomplete for cmdline
local cmp = require("cmp")

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
	},
})
