return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				direction = "horizontal", -- Open as a horizontal split
				size = 20, -- Height for horizontal split
				open_mapping = [[<C-t><C-t>]], -- Toggle with <Ctrl-t><Ctrl-t> in normal/insert modes
				hide_numbers = true, -- Hide line numbers
				shade_terminals = true, -- Apply shading
				start_in_insert = true, -- Start in insert mode
				insert_mappings = true, -- Allow <C-t><C-t> in insert mode
				terminal_mappings = true, -- Allow <C-t><C-t> in terminal mode
				persist_mode = true, -- Keep terminal buffer alive
				autochdir = true, -- Sync terminal dir with current file
				close_on_exit = true, -- Close when process exits
				shell = vim.o.shell, -- Use default shell
			})

			-- Ensure terminal opens in insert mode and looks clean
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*",
				callback = function()
					vim.cmd("startinsert")
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
					vim.opt_local.signcolumn = "no"
				end,
			})

			-- Terminal mode mapping for <C-t><C-t> to toggle
			vim.keymap.set("t", "<C-t><C-t>", [[<C-\><C-n><cmd>ToggleTerm<CR>]], { noremap = true, silent = true })

			-- Register with which-key
			local wk = require("which-key")
			wk.register({
				["<C-t>"] = {
					name = "Terminal",
					["<C-t>"] = { "<cmd>ToggleTerm<CR>", "Toggle Terminal", desc = "Toggle persistent terminal" }, -- <C-t><C-t>
				},
			}, { mode = "n" }) -- Normal mode

			wk.register({
				["<C-t>"] = {
					name = "Terminal",
					["<C-t>"] = { "<cmd>ToggleTerm<CR>", "Toggle Terminal", desc = "Toggle persistent terminal" }, -- <C-t><C-t>
				},
			}, { mode = "i" }) -- Insert mode

			wk.register({
				["<C-t><C-t>"] = {
					[[<C-\><C-n><cmd>ToggleTerm<CR>]],
					"Toggle Terminal",
					desc = "Toggle persistent terminal",
				}, -- <C-t><C-t>
			}, { mode = "t" }) -- Terminal mode
		end,
	},
}
