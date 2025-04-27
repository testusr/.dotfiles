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
		if client.name == "jdtls" then
			return client
		end
	end
	vim.notify("No jdtls client found", vim.log.levels.ERROR)
	return nil
end

-- Find references using LSP
local function find_references(class_name, bufnr, position)
	local client = get_lsp_client()
	if not client then
		return {}
	end
	local params = {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		position = position,
		context = { includeDeclaration = false },
	}
	local result = client.request_sync("textDocument/references", params, 200000, bufnr)
	if not result or result.err or not result.result then
		vim.notify("Failed to find references: " .. (result and result.err or "timeout"), vim.log.levels.ERROR)
		return {}
	end
	vim.notify("Found " .. #result.result .. " references", vim.log.levels.INFO)
	return result.result
end

-- Find beans
M.find_beans = function()
	local bufnr = api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]
	local query = ts.query.parse("java", [[(class_declaration name: (identifier) @class_name)]])
	local beans = {}
	for id, node in query:iter_captures(tree:root(), bufnr) do
		if query.captures[id] == "class_name" then
			table.insert(beans, ts.get_node_text(node, bufnr))
		end
	end
	return beans
end

-- Convert bean to record with builder (unchanged)
M.convert_bean_to_record_with_builder = function(class_name)
	local bufnr = api.nvim_get_current_buf()
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
	local fields, methods, package_line, imports = {}, {}, "", {}
	local seen_fields, seen_methods = {}, {}
	for id, node in query:iter_captures(tree:root(), bufnr) do
		local capture_name = query.captures[id]
		local text = ts.get_node_text(node, bufnr)
		if capture_name == "package" then
			package_line = "package " .. text .. ";"
		elseif capture_name == "import" then
			table.insert(imports, "import " .. text .. ";")
		elseif capture_name == "class_name" and text ~= class_name then
			goto continue
		elseif capture_name == "field_name" and not seen_fields[text] then
			local parent = node:parent():parent()
			local field_type_node = parent:child(1)
			if field_type_node and field_type_node:type() == "modifiers" then
				field_type_node = parent:child(2)
			end
			table.insert(fields, { type = ts.get_node_text(field_type_node, bufnr), name = text })
			seen_fields[text] = true
		elseif
			capture_name == "method_name" and not (text:match("^get.") or text:match("^set.") or text:match("^is."))
		then
			local method_node = node:parent()
			local params = ts.get_node_text(method_node:child(3), bufnr) or "()"
			local return_type = ts.get_node_text(method_node:child(1), bufnr)
			local body = ts.get_node_text(method_node:child(4), bufnr) or "{ }"
			local method_key = text .. params
			if not seen_methods[method_key] then
				local body_lines = vim.split(body, "\n", { plain = true, trimempty = true })
				if body_lines[1]:match("^%s*{$") then
					table.remove(body_lines, 1)
				end
				if body_lines[#body_lines]:match("^%s*}$") then
					table.remove(body_lines, #body_lines)
				end
				for i, line in ipairs(body_lines) do
					body_lines[i] = "        " .. line:gsub("^%s+", "")
				end
				table.insert(
					methods,
					{ signature = "    public " .. return_type .. " " .. text .. params, body_lines = body_lines }
				)
				seen_methods[method_key] = true
			end
		end
		::continue::
	end
	if #fields == 0 then
		vim.notify("No fields found for " .. class_name, vim.log.levels.ERROR)
		return
	end
	local record_lines = { package_line, "" }
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
		for _, line in ipairs(method.body_lines) do
			table.insert(record_lines, line)
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

-- Main conversion function
M.convert_and_update_references = function(class_name)
	local bufnr = api.nvim_get_current_buf()
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]
	local query_class = ts.query.parse("java", [[(class_declaration name: (identifier) @class_name)]])
	local class_node
	for id, node in query_class:iter_captures(tree:root(), bufnr) do
		if query_class.captures[id] == "class_name" and ts.get_node_text(node, bufnr) == class_name then
			class_node = node
			break
		end
	end
	if not class_node then
		vim.notify("Class " .. class_name .. " not found in current buffer", vim.log.levels.ERROR)
		return
	end
	local start_row, start_col = class_node:start()
	local position = { line = start_row, character = start_col }
	local references = find_references(class_name, bufnr, position)
	M.convert_bean_to_record_with_builder(class_name)
	for _, ref in ipairs(references) do
		local uri = ref.uri
		local ref_bufnr = vim.uri_to_bufnr(uri)
		if not api.nvim_buf_is_loaded(ref_bufnr) then
			api.nvim_command("badd " .. vim.uri_to_fname(uri))
		end
		M.update_usages_in_buffer(class_name, ref_bufnr)
	end
end

-- Enhanced update_usages_in_buffer function with fixes
M.update_usages_in_buffer = function(class_name, bufnr)
	local parser = ts.get_parser(bufnr, "java")
	local tree = parser:parse()[1]
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Query to find variables of type class_name
	local var_query = ts.query.parse(
		"java",
		[[
            (local_variable_declaration
                type: (_) @type
                (variable_declarator name: (identifier) @var_name))
            (field_declaration
                type: (_) @type
                (variable_declarator name: (identifier) @var_name))
        ]]
	)
	local variables = {}
	local function is_type_match(type_node)
		local type_text = ts.get_node_text(type_node, bufnr)
		return type_text == class_name or type_text:match("%." .. class_name .. "$")
	end
	for _, match in var_query:iter_matches(tree:root(), bufnr) do
		local type_node, var_name_node = match[1], match[2]
		if is_type_match(type_node) then
			table.insert(variables, ts.get_node_text(var_name_node, bufnr))
		end
	end

	-- Query for object creations and method invocations
	local usage_query = ts.query.parse(
		"java",
		[[
            (object_creation_expression
                type: (type_identifier) @class_name
                arguments: (argument_list) @args) @creation
            (method_invocation
                object: [
                    (identifier) @obj_id
                    (field_access field: (identifier) @obj_field)
                ]
                name: (identifier) @method_name
                arguments: (argument_list) @args) @method
        ]]
	)

	local changes = {}
	local setters = {}
	local processed_nodes = {} -- Track processed nodes to avoid duplicates

	for id, node in usage_query:iter_captures(tree:root(), bufnr) do
		local capture_name = usage_query.captures[id]
		local row, col = node:start()
		local _, end_col = node:end_()

		-- Skip if already processed
		if processed_nodes[node:id()] then
			goto continue
		end

		-- Handle object creation
		if capture_name == "class_name" and ts.get_node_text(node, bufnr) == class_name then
			local parent = node:parent()
			local p_row, p_col = parent:start()
			local _, p_end_col = parent:end_()
			changes[p_row + 1] = { start_col = p_col, end_col = p_end_col, text = class_name .. ".builder().build()" }
			processed_nodes[parent:id()] = true
		elseif capture_name == "method" then
			local obj_node = node:named_child(0)
			local method_name_node = node:named_child(1)
			local args_node = node:named_child(2)
			local obj_text = ts.get_node_text(obj_node, bufnr)
			local obj_full_text = obj_node:type() == "identifier" and obj_text
				or ts.get_node_text(obj_node:parent(), bufnr)
			local target_name = obj_node:type() == "identifier" and obj_text or obj_text -- Use field name for field_access
			local is_target = vim.tbl_contains(variables, target_name)
			if is_target then
				local method_name = ts.get_node_text(method_name_node, bufnr)
				-- Handle setters
				if method_name:match("^set.") then
					local args_text = ts.get_node_text(args_node, bufnr):sub(2, -2)
					local field_name = method_name:match("^set(.+)")
					local cap_field_name = field_name:sub(1, 1):upper() .. field_name:sub(2)
					local with_clause = ".with" .. cap_field_name .. "(" .. args_text .. ")"
					table.insert(setters, {
						row = row,
						obj = obj_full_text,
						with = with_clause,
						start_col = col,
						end_col = end_col,
						node_id = node:id(),
					})
					processed_nodes[node:id()] = true
				-- Handle getters
				elseif method_name:match("^get.") or method_name:match("^is.") then
					local field_name = method_name:match("^get(.+)") or method_name:match("^is(.+)")
					field_name = field_name:sub(1, 1):lower() .. field_name:sub(2)
					changes[row + 1] =
						{ start_col = col, end_col = end_col, text = obj_full_text .. "." .. field_name .. "()" }
					processed_nodes[node:id()] = true
				end
			end
		end
		::continue::
	end

	-- Group consecutive setters
	table.sort(setters, function(a, b)
		return a.row < b.row
	end)
	local grouped_setters = {}
	local current_group = nil
	for _, setter in ipairs(setters) do
		if current_group and setter.obj == current_group.obj and setter.row == current_group.end_row + 1 then
			table.insert(current_group.withs, setter.with)
			current_group.end_row = setter.row
			current_group.end_col = setter.end_col
		else
			if current_group then
				table.insert(grouped_setters, current_group)
			end
			current_group = {
				obj = setter.obj,
				start_row = setter.row,
				end_row = setter.row,
				start_col = setter.start_col,
				end_col = setter.end_col,
				withs = { setter.with },
			}
		end
	end
	if current_group then
		table.insert(grouped_setters, current_group)
	end

	-- Apply grouped setter changes
	for _, group in ipairs(grouped_setters) do
		local new_text = group.obj .. " = " .. group.obj .. ".toBuilder()" .. table.concat(group.withs) .. ".build()"
		-- Check if the line already ends with a semicolon
		local line_content = lines[group.start_row + 1]
		if not line_content:match(";%s*$") then
			new_text = new_text .. ";"
		end
		changes[group.start_row + 1] = { start_col = group.start_col, end_col = group.end_col, text = new_text }
	end

	-- Apply all changes in reverse order to avoid offset issues
	for line_num = #lines, 1, -1 do
		local change = changes[line_num]
		if change then
			lines[line_num] = lines[line_num]:sub(1, change.start_col)
				.. change.text
				.. lines[line_num]:sub(change.end_col + 1)
		end
	end
	api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

-- Telescope picker
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
			attach_mappings = function(prompt_bufnr)
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
