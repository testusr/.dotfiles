local M = {}

local ts = vim.treesitter
local telescope = require("telescope.builtin")

-- Find beans in the current buffer
M.find_beans = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]

	local query_str =
		table.concat(vim.fn.readfile("/Users/thorstenruhl/.dotfiles/nvim/.config/nvim/queries/java/beans.scm"), "\n")
	local query = ts.query.parse("java", query_str)

	local beans = {}
	local seen_classes = {}

	for id, node, _ in query:iter_captures(tree:root(), bufnr) do
		-- Check if the node is inside a class_declaration
		local parent = node:parent()
		if parent and parent:type() == "class_declaration" and node:type() == "identifier" then
			local class_name = ts.get_node_text(node, bufnr)
			if not seen_classes[class_name] then
				vim.print("Found bean class:", class_name)
				seen_classes[class_name] = true
				table.insert(beans, class_name)
			end
		end
	end

	vim.print("Final list of beans:", beans)
	return beans
end
-- Your provided function, now part of the module
M.convert_bean_to_record_with_builder = function(class_name)
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local fields = {}
	local class_start, class_end = nil, nil
	local methods_start, methods_end = nil, nil

	-- Parse fields and locate methods
	for i, line in ipairs(lines) do
		if line:match("class%s+" .. class_name) then
			class_start = i - 1
		elseif class_start and line:match("private%s+%w+%s+%w+%s*;") then
			local type, name = line:match("private%s+(%w+)%s+(%w+)%s*;")
			table.insert(fields, { type = type, name = name })
		elseif class_start and line:match("public%s+%w+%s+get[A-Z]%w*%(%)") then
			methods_start = i - 1
		elseif methods_start and line:match("}") then
			methods_end = i -- Capture the last method
		end
	end

	if not class_start or not methods_end then
		vim.notify("Could not parse class " .. class_name, vim.log.levels.ERROR)
		return
	end

	-- Generate record with builder
	local record_lines = {
		"public record " .. class_name .. "(" .. table.concat(
			vim.tbl_map(function(f)
				return f.type .. " " .. f.name
			end, fields),
			", "
		) .. ") {",
		"  public static Builder builder() { return new Builder(); }",
		"  public Builder toBuilder() {",
		"    Builder builder = new Builder();",
	}
	for _, field in ipairs(fields) do
		table.insert(record_lines, "    builder." .. field.name .. "(" .. field.name .. ");")
	end
	table.insert(record_lines, "    return builder;")
	table.insert(record_lines, "  }")
	table.insert(record_lines, "  public static class Builder {")
	for _, field in ipairs(fields) do
		table.insert(record_lines, "    private " .. field.type .. " " .. field.name .. ";")
	end
	for _, field in ipairs(fields) do
		table.insert(
			record_lines,
			"    public Builder " .. field.name .. "(" .. field.type .. " " .. field.name .. ") {"
		)
		table.insert(record_lines, "      this." .. field.name .. " = " .. field.name .. ";")
		table.insert(record_lines, "      return this;")
		table.insert(record_lines, "    }")
	end
	table.insert(record_lines, "    public " .. class_name .. " build() {")
	table.insert(record_lines, "      return new " .. class_name .. "(" .. table.concat(
		vim.tbl_map(function(f)
			return f.name
		end, fields),
		", "
	) .. ");")
	table.insert(record_lines, "    }")
	table.insert(record_lines, "  }")
	table.insert(record_lines, "}")

	-- Replace old class and methods with the new record
	vim.api.nvim_buf_set_lines(bufnr, class_start, methods_end + 1, false, record_lines)
	vim.lsp.buf.format()
end

-- Update bean usages
M.update_usages = function(class_name)
	-- Request all references from LSP
	local params = {
		textDocument = { uri = vim.uri_from_bufnr(0) },
		position = { line = 0, character = 0 }, -- Start search from top of file
		context = { includeDeclaration = false }, -- Ignore class definition
	}

	vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, _)
		if err then
			vim.notify("LSP error while finding references: " .. err.message, vim.log.levels.ERROR)
			return
		end

		if not result or #result == 0 then
			vim.notify("No references found for " .. class_name, vim.log.levels.WARN)
			return
		end

		local references = {}
		for _, ref in ipairs(result) do
			local uri = ref.uri
			local bufnr = vim.uri_to_bufnr(uri)

			if not vim.api.nvim_buf_is_loaded(bufnr) then
				vim.fn.bufload(bufnr) -- Load buffer if not already loaded
			end

			table.insert(references, { bufnr = bufnr, range = ref.range })
		end

		local replacements = {}

		-- Process each file containing references
		for _, ref in ipairs(references) do
			local bufnr = ref.bufnr

			-- Save the current undo option
			local original_undofile = vim.api.nvim_buf_get_option(bufnr, "undofile")

			-- Temporarily disable undo file
			vim.api.nvim_buf_set_option(bufnr, "undofile", false)

			local parser = ts.get_parser(bufnr, "java")
			local tree = parser:parse()[1]

			local query_path = vim.fn.expand("~/.dotfiles/nvim/.config/nvim/queries/java/bean_usage.scm")
			local success, query_data = pcall(vim.fn.readfile, query_path)

			if not success then
				vim.notify("Failed to read Treesitter query file: " .. query_path, vim.log.levels.ERROR)
				return
			end

			local query = ts.query.parse("java", table.concat(query_data, "\n"))

			-- Iterate over all setter calls in the reference file
			for _, node, _ in query:iter_captures(tree:root(), bufnr) do
				local method_node = node:named_child(1)
				if method_node == nil then
					vim.print("Skipping node, no method name found")
					goto continue
				end

				local method_name = ts.get_node_text(method_node, bufnr)
				local start_row, start_col, end_row, end_col = node:range()

				-- Handle setter replacements
				if method_name:match("^set[A-Z]") then
					local field_node = node:named_child(2)
					if field_node == nil then
						vim.print("Skipping setter, no field node found")
						goto continue
					end

					local field_name = method_name:sub(4, 4):lower() .. method_name:sub(5) -- Convert to camelCase
					local instance_node = node:named_child(0)
					if instance_node == nil then
						vim.print("Skipping setter, no instance node found")
						goto continue
					end

					local instance_name = ts.get_node_text(instance_node, bufnr)
					local arg = ts.get_node_text(field_node:named_child(0), bufnr)

					-- Replace with builder pattern
					table.insert(replacements, {
						row = start_row,
						col = start_col,
						end_row = end_row,
						end_col = end_col,
						text = instance_name
							.. " = "
							.. instance_name
							.. ".toBuilder()"
							.. "."
							.. field_name
							.. "("
							.. arg
							.. ").build();",
					})
				end

				::continue::
			end

			-- Apply all replacements in the file
			for _, rep in ipairs(replacements) do
				vim.api.nvim_buf_set_text(bufnr, rep.row, rep.col, rep.end_row, rep.end_col, { rep.text })
			end

			-- Save the file after modifications
			vim.api.nvim_buf_call(bufnr, function()
				vim.cmd("write")
			end)

			-- Restore the original undo file setting
			vim.api.nvim_buf_set_option(bufnr, "undofile", original_undofile)
		end

		vim.notify("Usages updated across all project files!", vim.log.levels.INFO)
	end)
end
-- Interactive selection with Telescope
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

M.select_beans_to_convert = function()
	local beans = M.find_beans()
	if #beans == 0 then
		vim.notify("No beans found in current file", vim.log.levels.WARN)
		return
	end

	pickers
		.new({}, {
			prompt_title = "Select Beans to Convert to Records",
			finder = finders.new_table({
				results = beans,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						M.convert_bean_to_record_with_builder(selection[1])
						M.update_usages(selection[1])
					end
				end)
				return true
			end,
		})
		:find()
end

return M
