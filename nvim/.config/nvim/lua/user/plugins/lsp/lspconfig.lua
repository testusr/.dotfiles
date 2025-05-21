return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness
		local which_key = require("which-key")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			-- LSP keybindings
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				which_key.register({
					c = {
						name = "Code",
						c = {
							name = "Comment", -- Existing comment subgroup
							c = {
								'<cmd>lua require("Comment.api").toggle.linewise.current()<CR>',
								"Toggle Line Comment",
							}, -- <leader>ccc
							b = {
								'<cmd>lua require("Comment.api").toggle.blockwise.current()<CR>',
								"Toggle Block Comment",
							}, -- <leader>ccb
						},
						l = {
							name = "LSP",
							r = { "<cmd>Telescope lsp_references<CR>", "Show References", desc = "Show LSP references" }, -- <leader>clr
							D = { vim.lsp.buf.declaration, "Go to Declaration", desc = "Go to declaration" }, -- <leader>clD
							d = {
								"<cmd>Telescope lsp_definitions<CR>",
								"Show Definitions",
								desc = "Show LSP definitions",
							}, -- <leader>cld
							i = {
								"<cmd>Telescope lsp_implementations<CR>",
								"Show Implementations",
								desc = "Show LSP implementations",
							}, -- <leader>cli
							t = {
								"<cmd>Telescope lsp_type_definitions<CR>",
								"Show Type Definitions",
								desc = "Show LSP type definitions",
							}, -- <leader>clt
							a = { vim.lsp.buf.code_action, "Code Actions", desc = "See available code actions" }, -- <leader>cla (replaces <leader>ca)
							n = { vim.lsp.buf.rename, "Smart Rename", desc = "Smart rename" }, -- <leader>cln (replaces <leader>rn)
							B = {
								"<cmd>Telescope diagnostics bufnr=0<CR>",
								"Buffer Diagnostics",
								desc = "Show buffer diagnostics",
							}, -- <leader>clB (replaces <leader>D)
							l = { vim.diagnostic.open_float, "Line Diagnostics", desc = "Show line diagnostics" }, -- <leader>cll (replaces <leader>d)
							p = { vim.diagnostic.goto_prev, "Previous Diagnostic", desc = "Go to previous diagnostic" }, -- <leader>clp (replaces [d)
							n = { vim.diagnostic.goto_next, "Next Diagnostic", desc = "Go to next diagnostic" }, -- <leader>cln (replaces ]d)
							k = { vim.lsp.buf.hover, "Show Documentation", desc = "Show documentation for cursor" }, -- <leader>clk (replaces K in <leader> scope)
							s = { ":LspRestart<CR>", "Restart LSP", desc = "Restart LSP" }, -- <leader>cls (replaces <leader>rs)
						},
					},
				}, { prefix = "<leader>", mode = "n", buffer = ev.buf }) -- Normal mode

				which_key.register({
					c = {
						name = "Code",
						l = {
							name = "LSP",
							a = { vim.lsp.buf.code_action, "Code Actions", desc = "See available code actions" }, -- <leader>cla
						},
					},
				}, { prefix = "<leader>", mode = "v", buffer = ev.buf }) -- Visual mode

				which_key.register({
					g = {
						name = "Go",
						R = { "<cmd>Telescope lsp_references<CR>", "Show References", desc = "Show LSP references" },
						D = { vim.lsp.buf.declaration, "Go to Declaration", desc = "Go to declaration" },
						d = { "<cmd>Telescope lsp_definitions<CR>", "Show Definitions", desc = "Show LSP definitions" },
						i = {
							"<cmd>Telescope lsp_implementations<CR>",
							"Show Implementations",
							desc = "Show LSP implementations",
						},
						t = {
							"<cmd>Telescope lsp_type_definitions<CR>",
							"Show Type Definitions",
							desc = "Show LSP type definitions",
						},
					},
					K = { vim.lsp.buf.hover, "Show Documentation", desc = "Show documentation for cursor" },
				}, { mode = "n", buffer = ev.buf }) -- Non-<leader> mappings
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["graphql"] = function()
				-- configure graphql language server
				lspconfig["graphql"].setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,
			["lua_ls"] = function()
				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				})
			end,
		})
	end,
}
