return {
	{
		"otavioschwanck/new-file-template.nvim",
		opts = {
			disable_insert = true, -- Stay in normal mode after template insertion
			disable_autocmd = false, -- Use custom autocommand in java.lua
			disable_filetype = {}, -- Allow all filetypes
			disable_specific = {}, -- Allow all patterns
			suffix_as_filetype = false, -- Use vim.bo.filetype
		},
		config = function(_, opts)
			require("new-file-template").setup(opts)
			-- Set up which-key mappings
			local wk = require("which-key")
			wk.register({
				j = {
					name = "Java",
					t = { ":SelectJavaTemplate<CR>", "Select Java template" },
				},
			}, { prefix = "<leader>" })
		end,
	},
}
