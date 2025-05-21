return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- Import comment plugin safely
		local comment = require("Comment")
		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")
		local which_key = require("which-key")

		-- Enable comment with custom mappings
		comment.setup({
			-- For commenting tsx, jsx, svelte, html files
			pre_hook = ts_context_commentstring.create_pre_hook(),
			-- Keymappings
			toggler = {
				line = "<leader>ccc", -- <leader>ccc for line comments
				block = "<leader>ccb", -- <leader>ccb for block comments
			},
			opleader = {
				line = "<leader>ccc", -- <leader>ccc for line comments in visual mode
				block = "<leader>ccb", -- <leader>ccb for block comments in visual mode
			},
			mappings = {
				basic = true, -- Enable basic mappings (overridden by toggler/opleader)
				extra = false, -- Disable extra mappings (e.g., gco, gcA)
			},
		})

		-- Register with which-key
		which_key.register({
			c = {
				name = "Code", -- Group name for code-related mappings
				c = {
					name = "Comment", -- Subgroup for comment mappings
					c = { "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", "Toggle Line Comment" }, -- <leader>ccc
					b = { "<cmd>lua require('Comment.api').toggle.blockwise.current()<CR>", "Toggle Block Comment" }, -- <leader>ccb
				},
			},
		}, { prefix = "<leader>", mode = "n" }) -- Normal mode

		which_key.register({
			c = {
				name = "Code",
				c = {
					name = "Comment",
					c = {
						"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
						"Toggle Line Comment",
					}, -- <leader>ccc
					b = {
						"<esc><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>",
						"Toggle Block Comment",
					}, -- <leader>ccb
				},
			},
		}, { prefix = "<leader>", mode = "v" }) -- Visual mode
	end,
}
