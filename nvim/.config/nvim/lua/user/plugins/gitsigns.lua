return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		-- Navigation
		{
			"]h",
			function()
				require("gitsigns").next_hunk()
			end,
			desc = "Next hunk",
		},
		{
			"[h",
			function()
				require("gitsigns").prev_hunk()
			end,
			desc = "Previous hunk",
		},
	},
	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			local wk = require("which-key")

			wk.register({
				gs = {
					name = "+Git",
					s = {
						function()
							gs.stage_hunk()
						end,
						"Stage hunk",
					},
					r = {
						function()
							gs.reset_hunk()
						end,
						"Reset hunk",
					},
					S = {
						function()
							gs.stage_buffer()
						end,
						"Stage buffer",
					},
					R = {
						function()
							gs.reset_buffer()
						end,
						"Reset buffer",
					},
					u = {
						function()
							gs.undo_stage_hunk()
						end,
						"Undo stage hunk",
					},
					p = {
						function()
							gs.preview_hunk()
						end,
						"Preview hunk",
					},
					b = {
						function()
							gs.blame_line({ full = true })
						end,
						"Blame line",
					},
					B = {
						function()
							gs.toggle_current_line_blame()
						end,
						"Toggle line blame",
					},
					d = {
						function()
							gs.diffthis()
						end,
						"Diff this",
					},
					D = {
						function()
							gs.diffthis("~")
						end,
						"Diff this ~",
					},
				},
			}, {
				prefix = "<leader>",
				buffer = bufnr,
				mode = "n",
				silent = true,
				noremap = true,
				nowait = true,
			})

			-- Visual mode mappings
			vim.keymap.set("v", "<leader>gs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Stage hunk", buffer = bufnr })

			vim.keymap.set("v", "<leader>gr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Reset hunk", buffer = bufnr })

			-- Text object
			vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", {
				desc = "Select hunk",
				buffer = bufnr,
			})
		end,
	},
}
