return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewfile" }, -- when a new or existing file gets opened
	build = ":TSUpdate", -- run this whenever this plugin gets installed or updated
	dependencies = {
		"windwp/nvim-ts-autotag",
		"nvim-treesitter/playground", -- adding the treesitter playground to test queries
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- oconifigure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
			},
			-- enable better indentation
			indent = {
				enable = true,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"yaml",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"graphql",
				"bash",
				"lua",
				"dockerfile",
				"gitignore",
				"java",
				"python",
			},
			playground = { -- Enable playground
				enable = true,
				disable = {},
				updatetime = 25,
				persist_queries = false,
				keybindings = {
					toggle_query_editor = "o",
					toggle_hl_groups = "i",
					toggle_injected_languages = "t",
					toggle_anonymous_nodes = "a",
					toggle_language_display = "I",
					focus_language = "f",
					unfocus_language = "F",
					update = "R",
					goto_node = "<cr>",
					show_help = "?",
				},
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
