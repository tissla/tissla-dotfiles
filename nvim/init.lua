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

-- Ctrl keybindings for common operations
vim.api.nvim_set_keymap("n", "<C-z>", "u", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-z>", "<Esc>ua", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-y>", "<C-r>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-y>", "<Esc><C-r>a", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-c>", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-x>", '"+d', { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-v>", '<Esc>"+pa', { noremap = true, silent = true })

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

-- [[ Basic Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Custom keymaps
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })
vim.keymap.set("x", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv=gv")

-- Terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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

			vim.api.nvim_set_hl(0, "Search", { fg = "#8b5cf6", bg = "#ff9e64", bold = true })
			vim.api.nvim_set_hl(0, "SearchCount", { fg = "#1e1b29", bold = true })

			vim.api.nvim_set_hl(0, "Pmenu", { bg = "#2b263b", fg = "#c9c7d4" })
			vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#1e1b29" })
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- Mason
	{ "williamboman/mason.nvim", opts = {} },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
					map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

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
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								checkThirdParty = false,
							},
						},
					},
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

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
				"clangd",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
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
			-- vim.api.nvim_set_hl(0, "Normal", { bg = "#1e1b29" })
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#41395e" })

			vim.api.nvim_set_hl(0, "LineNr", { fg = "#6b7280", bg = "none" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bg = "none", bold = true })

			vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

			vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#6b7280", bg = "none" })

			vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
			vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })

			vim.api.nvim_set_hl(0, "Search", { fg = "#1e1b29", bg = "#8b5cf6", bold = true })
			vim.api.nvim_set_hl(0, "IncSearch", { fg = "#1e1b29", bg = "#f9e2af", bold = true })
			vim.api.nvim_set_hl(0, "CurSearch", { fg = "#1e1b29", bg = "#ff79c6" })
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

-- CMP for cmdline
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

-- vim: ts=2 sts=2 sw=2 et
