return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"folke/todo-comments.nvim",
	},

	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local wk = require("which-key")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})
		telescope.load_extension("fzf")

		-- which-key registration for Telescope
		wk.register({
			f = {
				name = "+Find",
				f = { "<cmd>Telescope find_files<cr>", "Find files" },
				r = { "<cmd>Telescope oldfiles<cr>", "Recent files" },
				s = { "<cmd>Telescope live_grep<cr>", "Live grep" },
				c = { "<cmd>Telescope grep_string<cr>", "Grep word under cursor" },
				t = { "<cmd>TodoTelescope<cr>", "Find todos" },
			},
		}, { prefix = "<leader>" })
	end,
}
