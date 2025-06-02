return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	opts = {
		focus = true,
	},
	cmd = "Trouble",
	config = function()
		local wk = require("which-key")

		wk.register({
			x = {
				name = "+Trouble",
				w = { "<cmd>Trouble diagnostics toggle<CR>", "Workspace diagnostics" },
				d = { "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", "Document diagnostics" },
				q = { "<cmd>Trouble quickfix toggle<CR>", "Quickfix list" },
				l = { "<cmd>Trouble loclist toggle<CR>", "Location list" },
				t = { "<cmd>Trouble todo toggle<CR>", "Todo list" },
			},
		}, {
			prefix = "<leader>",
			mode = "n",
			silent = true,
			noremap = true,
			nowait = true,
		})
	end,
}
