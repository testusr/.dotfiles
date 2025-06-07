return {
	"tpope/vim-dadbod",
	dependencies = {
		"kristijanhusak/vim-dadbod-ui",
		"kristijanhusak/vim-dadbod-completion",
		"nvim-lua/plenary.nvim",
		"folke/which-key.nvim",
	},
	config = function()
		local wk = require("which-key")

		-- Dadbod UI setup
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_win_position = "right"

		-- Which-key mappings under <leader>d
		wk.register({
			d = {
				name = "Dadbod",
				t = { ":DBUIToggle<CR>", "Toggle Dadbod UI" },
				f = { ":DBUIFindBuffer<CR>", "Find Buffer" },
				r = { ":DBUIRenameBuffer<CR>", "Rename Buffer" },
				l = { ":DBUILastQueryInfo<CR>", "Last Query Info" },
				q = { ":DBUIAddConnection<CR>", "Add Connection" },
			},
		}, { prefix = "<leader>" })
	end,
}
