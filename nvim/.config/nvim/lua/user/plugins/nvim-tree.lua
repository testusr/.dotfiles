return {
	"nvim-tree/nvim-tree.lua",
	lazy = false, -- load early so netrw is disabled right away
	keys = {
		{ "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
		{ "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Toggle explorer at file" },
		{ "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "Collapse explorer" },
		{ "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh explorer" },
		{ "<leader>e", name = "+Explorer" }, -- group label for which-key
	},
	init = function()
		-- disable netrw at the very start
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- enable true color
		vim.opt.termguicolors = true
	end,
	opts = {
		sort = {
			sorter = "case_sensitive",
		},
		view = {
			width = 45,
			relativenumber = true,
		},
		renderer = {
			group_empty = true,
			indent_markers = {
				enable = true,
			},
		},
		filters = {
			custom = { ".DS_Store" },
		},
		actions = {
			open_file = {
				window_picker = {
					enable = false,
				},
			},
		},
		git = {
			ignore = false,
		},
	},
}
