return {
	"rest-nvim/rest.nvim",
	-- brew install luarocks // might be necessary
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			table.insert(opts.ensure_installed, "http")
		end,
	},
	config = function()
		require("rest-nvim").setup()

		-- Set up which-key mappings
		local wk = require("which-key")
		wk.register({
			r = {
				name = "Rest.nvim",
				r = { "<cmd>Rest run<cr>", "Run request" },
				l = { "<cmd>Rest run last<cr>", "Re-run last request" },
				p = { "<cmd>Rest run preview<cr>", "Preview request" },
			},
		}, { prefix = "<leader>" })
	end,
}
