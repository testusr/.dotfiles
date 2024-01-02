local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
	local signs = {

		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		virtual_text = true, -- disable virtual text
		signs = {
			active = signs, -- show signs
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

-- Helper function for creating keymaps
function nnoremap(rhs, lhs, bufopts, desc)
  bufopts.desc = desc
  vim.keymap.set("n", rhs, lhs, bufopts)
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap
  print("lsp keymapping invoked")
	keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	-- keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap(bufnr, "n", "gh", "<cmd>Lspsaga lsp_finder<CR>", opts)
	keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts)
	keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
	keymap(bufnr, "n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)
	keymap(bufnr, "n", "<leader>la", "<cmd>Lspsaga code_action<cr>", opts)
	keymap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

  keymap(bufnr, "n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
  keymap(bufnr, "v", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>Lspsaga rename<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>Lspsaga rename ++project<CR>", opts)
  keymap(bufnr, "n", "gp", "<cmd>Lspsaga peek_definition<CR>", opts)
  keymap(bufnr, "n","gd", "<cmd>Lspsaga goto_definition<CR>", opts)
  keymap(bufnr, "n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", opts)
  -- keymap("n","gt", "<cmd>Lspsaga goto_type_definition<CR>", opts)
  keymap(bufnr, "n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
  keymap(bufnr, "n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>", opts)
  keymap(bufnr, "n", "<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", opts)
  keymap(bufnr, "n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
  keymap(bufnr, "n","<leader>o", "<cmd>Lspsaga outline<CR>", opts)
  keymap(bufnr, "n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
  -- keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>", opts)

  -- Call hierarchy
  keymap(bufnr, "n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>", opts)
  keymap(bufnr, "n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>", opts)

  -- Floating terminal
  keymap(bufnr, "n", "<A-d>", "<cmd>Lspsaga term_toggle<CR>", opts)
  keymap(bufnr, "t", "<A-d>", "<cmd>Lspsaga term_toggle<CR>", opts)
end

M.on_attach = function(client, bufnr)
	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false
	end

	if client.name == "sumneko_lua" then
		client.server_capabilities.documentFormattingProvider = false
	end

	lsp_keymaps(bufnr)
	local status_ok, illuminate = pcall(require, "illuminate")
	if not status_ok then
		return
	end
	illuminate.on_attach(client)
end

return M
