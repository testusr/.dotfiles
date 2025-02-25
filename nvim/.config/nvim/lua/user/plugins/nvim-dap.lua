return {
	-- Mason
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	-- DAP core
	"mfussenegger/nvim-dap",
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "lua" }, -- Installs local-lua-debugger-vscode
				automatic_setup = true, -- Automatically configures DAP adapters
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }, -- Added nvim-nio
	},
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup()
		end,
	},
	-- Which-Key and DAP keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
		config = function()
			vim.notify("Which-Key config running", vim.log.levels.INFO)

			-- Setup which-key
			local wk = require("which-key")
			wk.setup({
				plugins = { spelling = { enabled = true } },
				window = { border = "single" },
			})

			-- Setup DAP
			local dap = require("dap")
			dap.adapters.lua = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/lua-debugger",
				args = {},
			}
			dap.configurations.lua = {
				{
					type = "lua",
					request = "launch",
					name = "Debug current file",
					program = { lua = "lua", file = "${file}" },
					cwd = vim.fn.getcwd(),
					stopOnEntry = true,
				},
			}

			-- Setup DAP-UI (requires nvim-nio)
			local dapui = require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Register keybindings with error checking
			local ok, err = pcall(function()
				wk.add({
					{ "<F5>", dap.step_into, desc = "Step Into", mode = "n" },
					{ "<F6>", dap.step_over, desc = "Step Over", mode = "n" },
					{ "<F7>", dap.step_out, desc = "Step Out", mode = "n" },
					{ "<F8>", dap.continue, desc = "Continue", mode = "n" },
					{ "<F9>", dap.toggle_breakpoint, desc = "Toggle Breakpoint", mode = "n" },
					{ "<S-F8>", dap.terminate, desc = "Terminate", mode = "n" },
					{ "<A-F8>", dap.repl.toggle, desc = "Toggle REPL (Evaluate)", mode = "n" },
					{ "<S-F9>", dap.continue, desc = "Start/Continue Debugging", mode = "n" },
				})

				wk.add({
					{ "<leader>b", group = "Debug" },
					{
						"<leader>bB",
						function()
							dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
						end,
						desc = "Set Conditional Breakpoint",
						mode = "n",
					},
					{ "<leader>bu", dapui.toggle, desc = "Toggle DAP UI", mode = "n" },
					{ "<leader>bk", "<cmd>Telescope keymaps<cr>", desc = "Search Keymaps", mode = "n" },
				})
			end)
			if not ok then
				vim.notify("Error registering DAP keybindings: " .. err, vim.log.levels.ERROR)
			else
				vim.notify("DAP keybindings registered successfully", vim.log.levels.INFO)
			end
		end,
	},
}
