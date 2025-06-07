return {
	-- Plenary: Lua functions used by many plugins
	{
		"nvim-lua/plenary.nvim",
		lazy = true, -- Optional: Load only when required by other plugins
	},
	-- Tmux & split window navigation
	{
		"christoomey/vim-tmux-navigator",
		config = function()
			-- Optional: Add any specific configuration for vim-tmux-navigator
			vim.g.tmux_navigator_no_mappings = 1 -- Example: Disable default mappings
			-- Define custom keybindings if needed
			vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { silent = true })
			vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { silent = true })
			vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { silent = true })
			vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { silent = true })
		end,
	},
}
