return {
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- Optional: for file icons
		},
		config = function()
			-- Setup nvim-tree
			local nvim_tree = require("nvim-tree")
			local api = require("nvim-tree.api")
			nvim_tree.setup({
				sort = {
					sorter = "case_sensitive",
				},
				view = {
					width = 40, -- Default width (matches your NERDTree preference)
					side = "left",
				},
				renderer = {
					group_empty = true,
				},
				filters = {
					dotfiles = false,
				},
				-- Optional: Sync with current file’s directory
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
				update_focused_file = {
					enable = true,
					update_root = true,
				},
			})

			-- Custom functions for mappings
			local function open_or_focus_nvim_tree()
				if api.tree.is_visible() then
					-- Focus if already open
					api.tree.focus()
				else
					-- Open if closed
					api.tree.open()
				end
			end

			local function open_or_focus_and_reveal()
				if api.tree.is_visible() then
					-- Focus and reveal current file
					api.tree.focus()
					api.tree.find_file(vim.api.nvim_buf_get_name(0))
				else
					-- Open and reveal current file
					api.tree.open({ find_file = true })
				end
			end

			local function close_nvim_tree()
				if api.tree.is_visible() then
					api.tree.close()
				end
			end

			-- Register with which-key
			local wk = require("which-key")
			wk.register({
				e = {
					name = "Explorer",
					e = { open_or_focus_nvim_tree, "Open/Focus Explorer", desc = "Open nvim-tree or focus if open" }, -- <leader>ee
					f = { open_or_focus_and_reveal, "Find File", desc = "Open nvim-tree and reveal current file" }, -- <leader>ef
					c = { close_nvim_tree, "Close Explorer", desc = "Close nvim-tree" }, -- <leader>ec
				},
			}, { prefix = "<leader>", mode = "n" })
		end,
	},
}
