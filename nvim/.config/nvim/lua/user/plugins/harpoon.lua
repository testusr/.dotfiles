return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for Harpoon
		},
		config = function()
			-- Setup Harpoon
			local harpoon = require("harpoon")
			harpoon:setup({
				settings = {
					save_on_toggle = true, -- Save marks when toggling UI
					save_on_change = true, -- Save on every change
					mark_branch = false, -- Set to true for branch-specific marks
				},
				menu = {
					width = math.min(vim.api.nvim_win_get_width(0) - 4, 80), -- Dynamic width
				},
			})

			local harpoon = require("harpoon")
			local mark_file = function()
				harpoon:list():append()
			end
			local toggle_menu = function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end
			local nav_next = function()
				harpoon:list():next()
			end
			local nav_prev = function()
				harpoon:list():prev()
			end

			local wk = require("which-key")
			wk.register({
				{ keys = "<leader>h", group = "Harpoon" },
				{ keys = "<leader>hm", desc = "Mark current file for Harpoon", command = mark_file },
				{ keys = "<leader>hh", desc = "Toggle Harpoon menu", command = toggle_menu },
				{ keys = "<leader>hn", desc = "Go to next Harpoon file", command = nav_next },
				{ keys = "<leader>hp", desc = "Go to previous Harpoon file", command = nav_prev },
				{
					keys = "<leader>h1",
					desc = "Go to Harpoon file 1",
					command = function()
						harpoon:list():select(1)
					end,
				},
				{
					keys = "<leader>h2",
					desc = "Go to Harpoon file 2",
					command = function()
						harpoon:list():select(2)
					end,
				},
				{
					keys = "<leader>h3",
					desc = "Go to Harpoon file 3",
					command = function()
						harpoon:list():select(3)
					end,
				},
				{
					keys = "<leader>h4",
					desc = "Go to Harpoon file 4",
					command = function()
						harpoon:list():select(4)
					end,
				},
			}, { mode = "n" })
		end,
	},
}
