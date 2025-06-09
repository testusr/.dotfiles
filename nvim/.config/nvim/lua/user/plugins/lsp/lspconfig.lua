return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{ "folke/neodev.nvim", opts = {} },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"numToStr/Comment.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local which_key = require("which-key")
			local telescope_builtin = require("telescope.builtin")

			-- Custom repeat mechanism
			local last_mapping = ""
			local function track_mapping(mapping)
				return function()
					last_mapping = mapping
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapping, true, false, true), "n", false)
				end
			end
			local function repeat_last_mapping()
				if last_mapping ~= "" then
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(last_mapping, true, false, true), "n", false)
				else
					vim.notify("No mapping to repeat", vim.log.levels.WARN)
				end
			end
			vim.keymap.set("n", "<leader>.", repeat_last_mapping, { desc = "Repeat last mapping" })

			-- Configure Comment.nvim
			require("Comment").setup({
				mappings = { basic = true, extra = true },
			})

			-- LSP keybindings
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					which_key.register({
						["<leader>"] = { "<cmd>Telescope oldfiles<CR>", "Recent files" },
						f = {
							name = "File navigation",
							f = { "<cmd>Telescope find_files<CR>", "Go to file (fuzzy)" },
							F = {
								function()
									telescope_builtin.find_files({
										no_ignore = true,
										hidden = true,
										disable_fuzzy = true,
									})
								end,
								"Go to file (exact)",
							}, -- <leader>fF
							c = { "<cmd>Telescope live_grep<CR>", "Search for file content (fuzzy)" },
							C = {
								function()
									telescope_builtin.live_grep({
										additional_args = { "--fixed-strings", "--no-ignore", "--hidden" },
										prompt_title = "Live Grep (Exact Match)",
									})
								end,
								"Search for file content (exact)",
							}, -- <leader>fC
							r = { "<cmd>Telescope oldfiles<CR>", "Show recent files" },
							l = { "<cmd>Telescope jumplist<CR>", "Show recent locations" },
						},
						q = { "<cmd>bd<CR>", "Close active" },
						r = {
							name = "Refactoring menu",
							n = { vim.lsp.buf.rename, "Rename element" },
							a = { vim.lsp.buf.code_action, "Code Actions" },
							s = { ":LspRestart<CR>", "Restart LSP" },
						},
						g = {
							name = "Go to X",
							d = { "<cmd>Telescope lsp_definitions<CR>", "Go to Definition" },
							y = { "<cmd>Telescope lsp_type_definitions<CR>", "Go to Type Definition" },
							i = { "<cmd>Telescope lsp_implementations<CR>", "Go to Implementation" },
							u = { "<cmd>Telescope lsp_references<CR>", "Go to Usages" },
							b = { "<cmd>lua vim.fn.execute('normal! <C-o>')<CR>", "Go Back" },
							f = { "<cmd>lua vim.fn.execute('normal! <C-i>')<CR>", "Go Forward" },
							h = { track_mapping("<leader>gh"), "Show Call Hierarchy (Callers)" }, -- <leader>gh
							c = {
								name = "Call Hierarchy",
								i = { track_mapping("<leader>gci"), "Show Incoming Calls" }, -- <leader>gci
								o = { track_mapping("<leader>gco"), "Show Outgoing Calls" }, -- <leader>gco
							},
						},
						e = {
							name = "Error navigation",
							n = { vim.diagnostic.goto_next, "Go to next error" },
							p = { vim.diagnostic.goto_prev, "Go to previous error" },
							l = { vim.diagnostic.open_float, "Show line diagnostics" },
							B = { "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics" },
						},
						c = {
							name = "Comment",
							c = { "gcc", "Toggle Line Comment", remap = true },
							b = { "gbc", "Toggle Block Comment", remap = true },
						},
					}, { prefix = "<leader>", mode = "n", buffer = ev.buf })

					which_key.register({
						r = {
							name = "Refactoring menu",
							a = { vim.lsp.buf.code_action, "Code Actions" },
						},
					}, { prefix = "<leader>", mode = "v", buffer = ev.buf })

					which_key.register({
						K = { vim.lsp.buf.hover, "Show Documentation" },
					}, { mode = "n", buffer = ev.buf })

					-- Direct keymaps for call hierarchy
					vim.keymap.set("n", "<leader>gh", ":Telescope lsp_incoming_calls<CR>", opts)
					vim.keymap.set("n", "<leader>gci", ":Telescope lsp_incoming_calls<CR>", opts)
					vim.keymap.set("n", "<leader>gco", ":Telescope lsp_outgoing_calls<CR>", opts)
				end,
			})

			local capabilities = cmp_nvim_lsp.default_capabilities()
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			mason_lspconfig.setup({
				ensure_installed = { "lua_ls", "graphql", "jdtls" },
				handlers = {
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = capabilities,
						})
					end,
					["graphql"] = function()
						lspconfig.graphql.setup({
							capabilities = capabilities,
							filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
						})
					end,
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = { globals = { "vim" } },
									completion = { callSnippet = "Replace" },
								},
							},
						})
					end,
					["jdtls"] = function()
						lspconfig.jdtls.setup({
							capabilities = capabilities,
							settings = {
								java = {},
							},
						})
					end,
				},
			})
		end,
	},
}
