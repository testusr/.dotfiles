return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		local wk = require("which-key")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				java = { "google-java-format" },
			},
			format_on_save = false, -- ✅ disables auto-format on save
		})

		wk.register({
			m = {
				name = "+Format",
				p = {
					function()
						conform.format({
							lsp_fallback = true,
							async = false,
							timeout_ms = 1000,
						})
					end,
					"Format file or selection",
				},
			},
		}, {
			prefix = "<leader>",
			mode = { "n", "v" },
			silent = true,
			noremap = true,
			nowait = true,
		})
	end,
}
