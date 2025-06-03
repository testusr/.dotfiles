return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- Required for icons
	opts = {
		options = {
			mode = "tabs", -- Treat buffers as tabs
			separator_style = "slant", -- Slant separator style
		},
	},
	config = function(_, opts)
		-- Initialize bufferline with provided options
		require("bufferline").setup(opts)

		-- Define bufferline keybindings
		local keymap = vim.keymap.set
		local opts = { noremap = true, silent = true }

		-- Custom function to rename the current tab
		local function rename_tab()
			vim.ui.input({ prompt = "Enter new tab name: " }, function(name)
				if name and name ~= "" then
					require("bufferline").tab_rename(name, vim.api.nvim_get_current_tabpage())
				end
			end)
		end

		-- Bufferline shortcuts
		keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", opts) -- Next tab
		keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", opts) -- Previous tab
		keymap("n", "<leader>tc", ":BufferLineClose<CR>", opts) -- Close current tab
		keymap("n", "<leader>tC", ":BufferLineGroupClose<CR>", opts) -- Close all tabs in group
		keymap("n", "<leader>tl", ":BufferLineMoveNext<CR>", opts) -- Move tab right
		keymap("n", "<leader>th", ":BufferLineMovePrev<CR>", opts) -- Move tab left
		keymap("n", "<leader>tp", ":BufferLinePick<CR>", opts) -- Pick tab by letter
		keymap("n", "<leader>tr", rename_tab, opts) -- Rename current tab

		-- Register with which-key
		local which_key = require("which-key")
		which_key.register({
			t = {
				name = "Tabs", -- Category name in which-key
				c = { ":BufferLineClose<CR>", "Close Tab" },
				C = { ":BufferLineGroupClose<CR>", "Close Tab Group" },
				l = { ":BufferLineMoveNext<CR>", "Move Tab Right" },
				h = { ":BufferLineMovePrev<CR>", "Move Tab Left" },
				p = { ":BufferLinePick<CR>", "Pick Tab" },
				r = { rename_tab, "Rename Tab" }, -- Register rename function
			},
		}, { prefix = "<leader>", mode = "n" })
	end,
}
