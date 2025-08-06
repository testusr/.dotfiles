local function parse_dotenv(file_path)
  local env_vars = {}
  local file = io.open(file_path, "r")
  if not file then
    print("Error: Cannot open file " .. file_path)
    return env_vars
  end
  for line in file:lines() do
    line = line:match("^%s*(.-)%s*$") -- Trim whitespace
    if line and not line:match("^#") then -- Ignore comments
      local key, value = line:match("^([%w_]+)%s*=%s*(.-)%s*$")
      if key and value then
        env_vars[key] = value:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1') -- Strip quotes
      end
    end
  end
  file:close()
  return env_vars
end

 
local function share(key, value)
  local file_path = vim.fn.getcwd() .. '/.shared_env'
  local env_vars = parse_dotenv(file_path)  -- Reuse the parser function
  
  -- Update or add the key
  env_vars[key] = value
  
  -- Write back to file (dotenv format)
  local file = io.open(file_path, "w")
  if file then
    for k, v in pairs(env_vars) do
      file:write(k .. '=' .. v .. '\n')
    end
    file:close()
  else
    print("Error writing to shared_env")
  end
end

-- Expose as a global or command
_G.share = share  -- Use in Lua scripts: share("ACCESS_TOKEN", "new-value")

vim.api.nvim_create_user_command('ShareEnv', function(opts)
  local key = opts.args:match("^(%S+)")
  local value = opts.args:match("%S+%s+(.+)")
  if key and value then
    share(key, value)
  else
    print("Usage: :ShareEnv KEY VALUE")
  end
end, { nargs = '*' })


return {
  "rest-nvim/rest.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    opts = function (_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "http")
    end,
  },  
  config = function()
    -- Initialize Mason
    require("mason").setup()

    -- Default selected env
    _G.selected_env_file = vim.fn.getcwd() .. '/.env.dev'

    -- Merge function (no print for now; add back if debugging)
    local function get_merged_env()
      local shared_env = parse_dotenv(vim.fn.getcwd() .. '/.shared_env')
      local selected_env = parse_dotenv(_G.selected_env_file)
      local merged = vim.tbl_extend("force", shared_env, selected_env)
      return merged
    end

    local function reload_env()
      local merged = get_merged_env()
      for key, value in pairs(merged) do
        vim.fn.setenv(key, value)
      end
    end

    -- Load merged vars into shell env at startup
    reload_env()

    -- Updated share function: Write to file, then reload merged and set to shell env
    local function share(key, value)
      local file_path = vim.fn.getcwd() .. '/.shared_env'
      local env_vars = parse_dotenv(file_path)
      
      -- Update or add the key
      env_vars[key] = value
      
      -- Write back to file
      local file = io.open(file_path, "w")
      if file then
        for k, v in pairs(env_vars) do
          file:write(k .. '=' .. v .. '\n')
        end
        file:close()
      else
        print("Error writing to shared_env")
      end

      -- Reload merged (shared + selected) and set all to shell env
      reload_env()
    end

    -- Expose share
    _G.share = share

    -- rest.nvim v3 config (no custom_dynamic_variables needed)
    vim.g.rest_nvim = {
      skip_ssl_verification = true,
      log_level = "debug",
      env = {
        enable = false,  -- Disable built-in to rely on shell env
      },
      result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
        show_curl_command = true,
        formatters = {
          json = "jq",
        },
      },
    }

    -- Wrapper functions to reload env before running requests
    local function run_request()
      reload_env()
      vim.cmd("Rest run")
    end

    local function run_last_request()
      reload_env()
      vim.cmd("Rest last")
    end

    -- Custom command to select env file and reload merged into shell env
    vim.api.nvim_create_user_command('RestEnvSelect', function()
      local env_files = vim.fs.find(function(name) return name:match('%.env.*$') end, {
        path = vim.fn.getcwd(),
        type = "file",
        limit = math.huge,
      })
      vim.ui.select(env_files, { prompt = "Select environment file" }, function(selected)
        if selected then
          _G.selected_env_file = selected
          print("Selected env: " .. selected)
          -- Reload merged and set to shell env
          reload_env()
        end
      end)
    end, {})

    -- Which-key mappings
    local wk = require("which-key")
    wk.register({
      r = {
        name = "Rest.nvim",
        r = { run_request, "Run request" },
        l = { run_last_request, "Re-run last request" },
        e = { "<cmd>RestEnvSelect<cr>", "Select environment" },
      },
    }, { prefix = "<leader>" })
  end,
}
