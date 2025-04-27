return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				-- direction = "float", -- Open as a floating window
				direction = "horizontal", -- Open as a floating window

				float_opts = {
					border = "curved", -- Optional: Customize border
					width = 80,
					height = 20,
				},
				persist_mode = true, -- Keeps the terminal buffer alive
				autochdir = true, -- Optional: Sync terminal dir with current file
			})

			-- Register with which-key
			local wk = require("which-key")
			wk.register({
				t = {
					"<cmd>ToggleTerm<CR>",
					"Toggle persistent terminal",
				},
			}, { prefix = "<leader>" })
		end,
	},
}
