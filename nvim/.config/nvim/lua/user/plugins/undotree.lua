return {
	{
		"jiaoshijie/undotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/which-key.nvim",
		},
		config = function()
			require("undotree").setup({
				float_diff = true,
				layout = "left_bottom",
				position = "left",
				ignore_filetype = {
					"undotree",
					"undotreeDiff",
					"qf",
					"TelescopePrompt",
					"spectre_panel",
					"tsplayground",
				},
				window = {
					winblend = 30,
				},
				keymaps = {
					["j"] = "move_next",
					["k"] = "move_prev",
					["gj"] = "move2parent",
					["J"] = "move_change_next",
					["K"] = "move_change_prev",
					["<cr>"] = "action_enter",
					["p"] = "enter_diffbuf",
					["q"] = "quit",
				},
			})
			require("which-key").register({
				u = {
					name = "Undotree",
					u = {
						"<cmd>lua require('undotree').toggle()<cr>",
						"Toggle Undotree",
						mode = "n",
						noremap = true,
						silent = true,
					},
					f = {
						"<cmd>lua require('undotree').focus()<cr>",
						"Focus Undotree",
						mode = "n",
						noremap = true,
						silent = true,
					},
				},
			}, { prefix = "<leader>" })
		end,
	},
}
