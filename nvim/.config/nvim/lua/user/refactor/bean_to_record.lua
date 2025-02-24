local M = {}

local ts = vim.treesitter
local api = vim.api
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

-- Helper function to get the LSP client for Java
local function get_lsp_client()
	local clients = vim.lsp.get_active_clients()
	for _, client in ipairs(clients) do
		if client.name == "jdtls" then -- Adjust for your Java LSP server
			return client
		end
	end
	vim.notify("No jdtls client found", vim.log.levels.ERROR)
	return nil
end

-- Find all references to the bean class using LSP
local function find_references(class_name, bufnr, position)
	local client = get_lsp_client()
	if not client then
		vim.notify("No LSP client found for Java", vim.log.levels.WARN)
		return {}
	end

	local params = {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		position = position,
		context = { includeDeclaration = false }, -- Exclude the class declaration itself
	}

	vim.notify(
		"Requesting references for "
			.. class_name
			.. " at line "
			.. (position.line + 1)
			.. ", col "
			.. (position.character + 1),
		vim.log.levels.INFO
	)
	local result = client.request_sync("textDocument/references", params, 2000, bufnr)
	if not result then
		vim.notify("LSP request failed or timed out", vim.log.levels.ERROR)
		return {}
	elseif result.err then
		vim.notify("LSP error: " .. vim.inspect(result.err), vim.log.levels.ERROR)
		return {}
	elseif result.result then
		vim.notify("Found " .. #result.result .. " references", vim.log.levels.INFO)
		return result.result
	end
	vim.notify("No references returned by LSP", vim.log.levels.WARN)
	return {}
end

-- Find beans (class names) in the current buffer
M.find_beans = function()
	local bufnr = api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]

	local query = ts.query.parse(
		"java",
		[[
            (class_declaration
                name: (identifier) @class_name)
        ]]
	)

	local beans = {}
	for id, node in query:iter_captures(tree:root(), bufnr) do
		if query.captures[id] == "class_name" then
			local class_name = ts.get_node_text(node, bufnr)
			table.insert(beans, class_name)
		end
	end
	return beans
end

-- Convert a bean class to a record with builder
M.convert_bean_to_record_with_builder = function(class_name)
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]

	local query = ts.query.parse(
		"java",
		[[
            (package_declaration (scoped_identifier) @package)
            (import_declaration (scoped_identifier) @import)
            (class_declaration
                name: (identifier) @class_name
                body: (class_body
                    (field_declaration
                        (modifiers)? @modifiers
                        type: (_) @field_type
                        (variable_declarator name: (identifier) @field_name))
                    (method_declaration
                        (modifiers)? @method_modifiers
                        type: (_) @method_type
                        name: (identifier) @method_name
                        parameters: (formal_parameters) @method_params
                        body: (block) @method_body))
            )
        ]]
	)

	local fields = {}
	local methods = {}
	local package_line = ""
	local imports = {}
	local seen_fields = {}
	local seen_methods = {}

	for id, node, _ in query:iter_captures(tree:root(), bufnr) do
		local capture_name = query.captures[id]
		local text = ts.get_node_text(node, bufnr)

		if capture_name == "package" then
			package_line = "package " .. text .. ";"
		elseif capture_name == "import" then
			table.insert(imports, "import " .. text .. ";")
		elseif capture_name == "class_name" and text ~= class_name then
			goto continue
		elseif capture_name == "field_name" then
			if not seen_fields[text] then
				local parent = node:parent():parent()
				local field_type_node = parent:child(1)
				if field_type_node and field_type_node:type() == "modifiers" then
					field_type_node = parent:child(2)
				end
				local field_type = ts.get_node_text(field_type_node, bufnr)
				table.insert(fields, { type = field_type, name = text })
				seen_fields[text] = true
			end
		elseif capture_name == "method_name" then
			-- Exclude getters and setters (relaxed pattern: get/set/is followed by any character)
			if not (text:match("^get.") or text:match("^set.") or text:match("^is.")) then
				local method_node = node:parent()
				local params = ts.get_node_text(method_node:child(3), bufnr) or "()"
				local return_type = ts.get_node_text(method_node:child(1), bufnr)
				local body = ts.get_node_text(method_node:child(4), bufnr) or "{ }"
				local method_key = text .. params
				if not seen_methods[method_key] then
					local body_lines = vim.split(body, "\n", { plain = true, trimempty = true })
					if #body_lines > 0 and body_lines[1]:match("^%s*{$") then
						table.remove(body_lines, 1)
					end
					if #body_lines > 0 and body_lines[#body_lines]:match("^%s*}$") then
						table.remove(body_lines, #body_lines)
					end
					for i, line in ipairs(body_lines) do
						body_lines[i] = "        " .. line:gsub("^%s+", "")
					end
					table.insert(methods, {
						signature = "    public " .. return_type .. " " .. text .. params,
						body_lines = body_lines,
					})
					seen_methods[method_key] = true
				end
			end
		end
		::continue::
	end

	if #fields == 0 then
		vim.notify("No fields found for " .. class_name, vim.log.levels.ERROR)
		return
	end

	local record_lines = {}
	if package_line ~= "" then
		table.insert(record_lines, package_line)
		table.insert(record_lines, "")
	end
	for _, import in ipairs(imports) do
		table.insert(record_lines, import)
	end
	if #imports > 0 then
		table.insert(record_lines, "")
	end

	table.insert(record_lines, "public record " .. class_name .. "(")
	for i, field in ipairs(fields) do
		table.insert(record_lines, "    " .. field.type .. " " .. field.name .. (i < #fields and "," or ""))
	end
	table.insert(record_lines, ") {")
	table.insert(record_lines, "")

	for _, method in ipairs(methods) do
		table.insert(record_lines, method.signature .. " {")
		for _, body_line in ipairs(method.body_lines) do
			table.insert(record_lines, body_line)
		end
		table.insert(record_lines, "    }")
		table.insert(record_lines, "")
	end

	table.insert(record_lines, "    public Builder toBuilder() { return new Builder(this); }")
	table.insert(record_lines, "    public static Builder builder() { return new Builder(); }")
	table.insert(record_lines, "")

	table.insert(record_lines, "    public static final class Builder {")
	for _, field in ipairs(fields) do
		table.insert(record_lines, "        private " .. field.type .. " " .. field.name .. ";")
	end
	table.insert(record_lines, "")
	table.insert(record_lines, "        private Builder() {}")
	table.insert(record_lines, "        private Builder(" .. class_name .. " record) {")
	for _, field in ipairs(fields) do
		table.insert(record_lines, "            this." .. field.name .. " = record." .. field.name .. ";")
	end
	table.insert(record_lines, "        }")
	table.insert(record_lines, "")

	for _, field in ipairs(fields) do
		local cap_name = field.name:sub(1, 1):upper() .. field.name:sub(2)
		table.insert(
			record_lines,
			"        public Builder with" .. cap_name .. "(" .. field.type .. " " .. field.name .. ") {"
		)
		table.insert(record_lines, "            this." .. field.name .. " = " .. field.name .. ";")
		table.insert(record_lines, "            return this;")
		table.insert(record_lines, "        }")
		table.insert(record_lines, "")
	end

	table.insert(record_lines, "        public " .. class_name .. " build() {")
	table.insert(record_lines, "            return new " .. class_name .. "(" .. table.concat(
		vim.tbl_map(function(f)
			return f.name
		end, fields),
		", "
	) .. ");")
	table.insert(record_lines, "        }")
	table.insert(record_lines, "    }")
	table.insert(record_lines, "}")

	api.nvim_buf_set_lines(bufnr, 0, -1, false, record_lines)
end

-- Main function to process the bean-to-record conversion and update references
M.convert_and_update_references = function(class_name)
	local bufnr = api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]

	-- Find the class declaration position for LSP before conversion
	local query_class = ts.query.parse(
		"java",
		[[
            (class_declaration
                name: (identifier) @class_name)
        ]]
	)

	local class_node
	for id, node in query_class:iter_captures(tree:root(), bufnr) do
		if query_class.captures[id] == "class_name" then
			local node_text = ts.get_node_text(node, bufnr)
			if node_text == class_name then
				class_node = node
				break
			end
		end
	end

	if not class_node then
		vim.notify("Class " .. class_name .. " not found in current buffer", vim.log.levels.ERROR)
		return
	end

	-- Use the exact position of the class name identifier
	local start_row, start_col = class_node:start()
	local position = { line = start_row, character = start_col }
	vim.notify("Querying references at line " .. (start_row + 1) .. ", col " .. (start_col + 1), vim.log.levels.INFO)

	-- Get all references via LSP before conversion
	local references = find_references(class_name, bufnr, position)
	if #references == 0 then
		vim.notify("No references found for " .. class_name, vim.log.levels.WARN)
	end

	-- Perform the conversion to record
	M.convert_bean_to_record_with_builder(class_name)

	-- Process each reference after conversion
	for _, ref in ipairs(references) do
		local uri = ref.uri
		local ref_bufnr = vim.uri_to_bufnr(uri)

		-- Load the buffer if not already loaded
		if not api.nvim_buf_is_loaded(ref_bufnr) then
			api.nvim_command("badd " .. vim.uri_to_fname(uri))
		end

		-- Update the usages in this buffer
		M.update_usages_in_buffer(class_name, ref_bufnr)
	end
end

-- Update usages in a specific buffer
M.update_usages_in_buffer = function(class_name, bufnr)
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local query = ts.query.parse(
		"java",
		[[
            (object_creation_expression
                type: (type_identifier) @class_name)
            @creation
            (method_invocation
                object: (identifier) @obj
                name: (identifier) @method_name
                (#match? @method_name "^set.")) @setter
            (method_invocation
                object: (identifier) @obj
                name: (identifier) @method_name
                (#match? @method_name "^get.")) @getter_regular
            (method_invocation
                object: (identifier) @obj
                name: (identifier) @method_name
                (#match? @method_name "^is.")) @getter_is
        ]]
	)

	local changes = {}
	for id, node in query:iter_captures(tree:root(), bufnr) do
		local capture_name = query.captures[id]
		local row, col = node:start()
		local end_row, end_col = node:end_()

		if capture_name == "class_name" then
			local text = ts.get_node_text(node, bufnr)
			if text ~= class_name then
				goto continue
			end
		elseif capture_name == "creation" then
			changes[row + 1] = {
				start_col = col,
				end_col = end_col,
				text = class_name .. ".builder().build()",
			}
		elseif capture_name == "setter" then
			local obj_name = ts.get_node_text(node:child(0), bufnr)
			local method_name = ts.get_node_text(node:child(2), bufnr)
			local args = ts.get_node_text(node:child(3), bufnr):sub(2, -2) -- Strip parentheses
			local field_name = method_name:sub(4) -- Simply take everything after "set"
			local cap_field_name = field_name:sub(1, 1):upper() .. field_name:sub(2)
			local new_text = obj_name
				.. " = "
				.. obj_name
				.. ".toBuilder().with"
				.. cap_field_name
				.. "("
				.. args
				.. ").build()"
			changes[row + 1] = { start_col = col, end_col = end_col, text = new_text }
		elseif capture_name == "getter_regular" or capture_name == "getter_is" then
			local obj_name = ts.get_node_text(node:child(0), bufnr)
			local method_name = ts.get_node_text(node:child(2), bufnr)
			local prefix_length = method_name:match("^is") and 3 or 4 -- "is" is 2 chars + 1, "get" is 3 chars + 1
			local field_name = method_name:sub(prefix_length)
			field_name = field_name:sub(1, 1):lower() .. field_name:sub(2) -- Lowercase first letter
			changes[row + 1] = { start_col = col, end_col = end_col, text = obj_name .. "." .. field_name .. "()" }
		end
		::continue::
	end

	for line_num, change in pairs(changes) do
		lines[line_num] = lines[line_num]:sub(1, change.start_col)
			.. change.text
			.. lines[line_num]:sub(change.end_col + 1)
	end
	api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

-- Interactive selection with Telescope
M.select_beans_to_convert = function()
	local beans = M.find_beans()
	if #beans == 0 then
		vim.notify("No beans found in current file", vim.log.levels.WARN)
		return
	end

	pickers
		.new({}, {
			prompt_title = "Select Beans to Convert to Records",
			finder = finders.new_table({ results = beans }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						M.convert_and_update_references(selection[1])
					end
				end)
				return true
			end,
		})
		:find()
end

return M
