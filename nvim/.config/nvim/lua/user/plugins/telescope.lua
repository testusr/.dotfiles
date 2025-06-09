return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"folke/todo-comments.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin") -- Fix: Define builtin
			local wk = require("which-key")

			telescope.setup({
				defaults = {
					path_display = { "smart" },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous,
							["<C-j>"] = actions.move_selection_next,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						},
					},
				},
				pickers = {
					find_files = {
						find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--no-ignore" }, -- Use fd for exact file search
					},
					live_grep = {
						additional_args = { "--no-ignore", "--hidden" },
					},
				},
				extensions = {
					fzf = {
						fuzzy = true, -- Keep fuzzy for default searches
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})
			telescope.load_extension("fzf")

			-- Custom repeat mechanism
			local last_mapping = ""
			local function track_mapping(mapping)
				return function()
					last_mapping = mapping
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapping, true, false, true), "n", false)
				end
			end

			-- which-key registration for Telescope
			wk.register({
				f = {
					name = "File navigation", -- Align with IdeaVim
					f = { "<cmd>Telescope find_files<CR>", "Go to file (fuzzy)" },
					F = {
						function()
							builtin.find_files({
								find_command = {
									"fd",
									"--type",
									"f",
									"--strip-cwd-prefix",
									"--hidden",
									"--no-ignore",
									"--glob",
								}, -- Exact match with glob
								prompt_title = "Find Files (Exact Match)",
							})
						end,
						"Go to file (exact)",
					}, -- <leader>fF
					c = { "<cmd>Telescope live_grep<CR>", "Search for file content (fuzzy)" },
					C = {
						function()
							builtin.live_grep({
								additional_args = { "--fixed-strings", "--no-ignore", "--hidden" },
								prompt_title = "Live Grep (Exact Match)",
							})
						end,
						"Search for file content (exact)",
					}, -- <leader>fC
					r = { "<cmd>Telescope oldfiles<CR>", "Show recent files" },
					l = { "<cmd>Telescope jumplist<CR>", "Show recent locations" },
					s = { "<cmd>Telescope grep_string<CR>", "Grep word under cursor" },
					t = { "<cmd>TodoTelescope<CR>", "Find todos" },
				},
			}, { prefix = "<leader>" })
		end,
	},
}
