return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer", -- Source for text in buffer
			"hrsh7th/cmp-path", -- Source for file system paths
			"hrsh7th/cmp-nvim-lsp", -- Source for LSP
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
				dependencies = { "rafamadriz/friendly-snippets" },
			},
			"saadparwaiz1/cmp_luasnip", -- For autocompletion
			"onsails/lspkind.nvim", -- VS Code-like pictograms
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			local wk = require("which-key")

			-- Load VS Code-style snippets from friendly-snippets (includes Java, Python, TypeScript)
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Load custom Lua snippets from ~/.config/nvim/lua/snippets/
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })

			-- Enable snippet expansion for specific filetypes
			luasnip.filetype_extend("java", { "java" })
			luasnip.filetype_extend("python", { "python" })
			luasnip.filetype_extend("typescript", { "typescript", "javascript" })

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					-- Add snippet navigation
					["<Tab>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- Add LSP source for Java, Python, TypeScript
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				formatting = {
					format = lspkind.cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			})

			-- Register which-key mappings (normal mode)
			wk.register({
				i = {
					name = "+Completion",
					c = {
						function()
							cmp.complete()
						end,
						"Trigger completion",
					},
					e = {
						function()
							cmp.abort()
						end,
						"Abort completion",
					},
					s = {
						function()
							luasnip.expand()
						end,
						"Expand snippet",
					},
					n = {
						function()
							luasnip.jump(1)
						end,
						"Next snippet jump",
					},
					p = {
						function()
							luasnip.jump(-1)
						end,
						"Previous snippet jump",
					},
				},
			}, { prefix = "<leader>" })
		end,
	},
}
