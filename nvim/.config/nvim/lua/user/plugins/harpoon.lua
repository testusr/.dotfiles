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

			-- Custom functions for mappings
			local function mark_file()
				harpoon:list():add()
				vim.notify("Harpoon: Marked file", vim.log.levels.INFO)
			end

			local function toggle_menu()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end

			local function nav_next()
				harpoon:list():next()
			end

			local function nav_prev()
				harpoon:list():prev()
			end

			-- Register with which-key
			local wk = require("which-key")
			wk.register({
				h = {
					name = "Harpoon",
					m = { mark_file, "Mark File", desc = "Mark current file for Harpoon" }, -- <leader>hm
					h = { toggle_menu, "Toggle Menu", desc = "Toggle Harpoon menu" }, -- <leader>hh
					n = { nav_next, "Next File", desc = "Go to next Harpoon file" }, -- <leader>hn
					p = { nav_prev, "Previous File", desc = "Go to previous Harpoon file" }, -- <leader>hp
					["1"] = {
						function()
							harpoon:list():select(1)
						end,
						"File 1",
						desc = "Go to Harpoon file 1",
					}, -- <leader>h1
					["2"] = {
						function()
							harpoon:list():select(2)
						end,
						"File 2",
						desc = "Go to Harpoon file 2",
					}, -- <leader>h2
					["3"] = {
						function()
							harpoon:list():select(3)
						end,
						"File 3",
						desc = "Go to Harpoon file 3",
					}, -- <leader>h3
					["4"] = {
						function()
							harpoon:list():select(4)
						end,
						"File 4",
						desc = "Go to Harpoon file 4",
					}, -- <leader>h4
				},
			}, { prefix = "<leader>", mode = "n" })
		end,
	},
}
