return {
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			"ibhagwan/fzf-lua", -- optional
			"echasnovski/mini.pick", -- optional
		},
		config = function()
			-- Setup Neogit
			local neogit = require("neogit")
			neogit.setup({
				integrations = {
					diffview = true, -- Enable Diffview integration
				},
				signs = {
					section = { ">", "v" }, -- Customize signs
					item = { ">", "v" },
				},
				disable_commit_confirmation = false, -- Show commit confirmation
				auto_refresh = true, -- Auto-refresh status
			})

			-- Register with which-key
			local wk = require("which-key")
			wk.register({
				gn = { "<cmd>Neogit<CR>", "Open Neogit" },
			}, {
				prefix = "<leader>",
				mode = "n",
				silent = true,
				noremap = true,
				nowait = true,
			})
		end,
	},
}
