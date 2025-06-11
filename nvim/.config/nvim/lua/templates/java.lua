local utils = require("new-file-template.utils")

-- Helper function to compute package name
local function get_package(relative_path)
	local src_index = relative_path:find("src/main/java/") or relative_path:find("src/")
	local package = ""
	if src_index then
		local package_path = relative_path:sub(src_index + (relative_path:match("src/main/java/") and 14 or 5))
		package = package_path:gsub("/", "."):gsub("^%.", ""):gsub("%.%.", "."):gsub("%.?[^%.]+%.java$", "")
	end
	return package ~= "" and "package " .. package .. ";" or ""
end

-- Class template
local function class_template(relative_path, filename)
	local classname = vim.split(filename, "%.")[1]
	local package_line = get_package(relative_path)
	return [[
]] .. package_line .. [[


public class ]] .. classname .. [[ {
    // TODO: Add class components or methods
}
]]
end

-- Enum template
local function enum_template(relative_path, filename)
	local enumname = vim.split(filename, "%.")[1]:gsub("Enum$", "")
	local package_line = get_package(relative_path)
	return [[
]] .. package_line .. [[


public enum ]] .. enumname .. [[ {
    // TODO: Add enum constants
    VALUE1, VALUE2, VALUE3;
}
]]
end

-- Record template
local function record_template(relative_path, filename)
	local recordname = vim.split(filename, "%.")[1]:gsub("Record$", "")
	local package_line = get_package(relative_path)
	return [[
]] .. package_line .. [[


public record ]] .. recordname .. [[(String id, int value) {
    // TODO: Add record components or methods
}
]]
end

-- Interface template
local function interface_template(relative_path, filename)
	local interfacename = vim.split(filename, "%.")[1]:gsub("Interface$", "")
	local package_line = get_package(relative_path)
	return [[
]] .. package_line .. [[


public interface ]] .. interfacename .. [[ {
    // TODO: Add interface methods
    void exampleMethod();
}
]]
end

-- Template selection table
local templates = {
	{ name = "Class", pattern = ".*%.java$", content = class_template },
	{ name = "Enum", pattern = ".*Enum%.java$", content = enum_template },
	{ name = "Record", pattern = ".*Record%.java$", content = record_template },
	{ name = "Interface", pattern = ".*Interface%.java$", content = interface_template },
}

-- Function to apply template
local function apply_template(template, opts)
	local content = template.content(opts.relative_path, opts.filename)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
end

-- Main function to handle template selection
local function select_template(opts)
	-- Check if automatic selection is preferred (configurable via global variable)
	local use_auto = vim.g.java_template_auto or false
	if use_auto then
		for _, template in ipairs(templates) do
			if opts.filename:match(template.pattern) then
				apply_template(template, opts)
				return
			end
		end
		-- Fallback to class template if no pattern matches
		apply_template(templates[1], opts)
		return
	end

	-- Show dropdown for manual selection
	vim.ui.select(templates, {
		prompt = "Select Java template:",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		if choice then
			apply_template(choice, opts)
		end
	end)
end

-- Autocommand to trigger template selection for new .java files
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.java",
	callback = function()
		local opts = {
			full_path = vim.fn.expand("%:p"),
			relative_path = vim.fn.expand("%:p"),
			filename = vim.fn.expand("%:t"),
		}
		select_template(opts)
	end,
})

-- Manual command to trigger template selection for existing files
vim.api.nvim_create_user_command("SelectJavaTemplate", function()
	local opts = {
		full_path = vim.fn.expand("%:p"),
		relative_path = vim.fn.expand("%:p"),
		filename = vim.fn.expand("%:t"),
	}
	select_template(opts)
end, {})

--- @param opts table
---   A table containing the following fields:
---   - `full_path` (string): The full path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `relative_path` (string): The relative path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `filename` (string): The filename of the new file, e.g., "init.lua".
return function(opts)
	-- Keep pattern-based fallback for compatibility with new-file-template.nvim
	local template = {
		{ pattern = ".*Enum%.java$", content = enum_template },
		{ pattern = ".*Record%.java$", content = record_template },
		{ pattern = ".*Interface%.java$", content = interface_template },
		{ pattern = ".*%.java$", content = class_template },
	}
	return utils.find_entry(template, opts)
end
