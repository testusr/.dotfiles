
-- Java Language Server configuration.
-- Locations:
-- 'nvim/ftplugin/java.lua'.
-- 'nvim/lang-servers/intellij-java-google-style.xml'

local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify "JDTLS not found, install with `:LspInstall jdtls`"
  return
end

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local jdtls_dir = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local config_dir = jdtls_dir .. '/config_mac'
local plugins_dir = jdtls_dir .. '/plugins/'
local path_to_jar = plugins_dir .. 'org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'
local lombok_path = jdtls_dir .. "/lombok.jar"


local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
  return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name
os.execute("mkdir -p " .. workspace_dir)

-- Helper function for creating keymaps
function nnoremap(rhs, lhs, bufopts, desc)
  bufopts.desc = desc
  vim.keymap.set("n", rhs, lhs, bufopts)
end

local log_file = io.open("/tmp/my_log_file.txt", "a")
log_file:write("java.lua was processed \n")
log_file:close()

--
-- The on_attach function is used to set key maps after the language server
-- attaches to the current buffer
--local on_attach = function(client, bufnr)
  -- Regular Neovim LSP client keymappings
  local log_file = io.open("/tmp/my_log_file.txt", "a")
  log_file:write("on_attach i was called \n")
  log_file:close()
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  nnoremap('gD', vim.lsp.buf.declaration, bufopts, "Go to declaration")
  nnoremap('gd', vim.lsp.buf.definition, bufopts, "Go to definition")
  nnoremap('gi', vim.lsp.buf.implementation, bufopts, "Go to implementation")
  nnoremap('K', vim.lsp.buf.hover, bufopts, "Hover text")
  nnoremap('<C-k>', vim.lsp.buf.signature_help, bufopts, "Show signature")
  nnoremap('<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
  nnoremap('<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")
  nnoremap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts, "List workspace folders")
  nnoremap('<leader>D', vim.lsp.buf.type_definition, bufopts, "Go to type definition")
  nnoremap('<leader>rn', vim.lsp.buf.rename, bufopts, "Rename")
  nnoremap('<leader>ca', vim.lsp.buf.code_action, bufopts, "Code actions")
  vim.keymap.set('v', "<leader>ca", "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
    { noremap=true, silent=true, buffer=bufnr, desc = "Code actions" })
  nnoremap('<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts, "Format file")

  -- Java extensions provided by jdtls
  nnoremap("<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
  nnoremap("<leader>ev", jdtls.extract_variable, bufopts, "Extract variable")
  nnoremap("<leader>ec", jdtls.extract_constant, bufopts, "Extract constant")
  vim.keymap.set('v', "<leader>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
    { noremap=true, silent=true, buffer=bufnr, desc = "Extract method" })
--end


-- Main Config
local config = {

  on_attach = on_attach, -- we pass our on_attach keybindings to the condfigurations map:1
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    '/usr/local/Cellar/openjdk/19.0.2/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-javaagent:' .. lombok_path,
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    '-jar', path_to_jar,
    '-configuration', config_dir,
    '-data', workspace_dir
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      home = '/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home',
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home",
          },
          {
            name = "JavaSE-12",
            path = "/Library/Java/JavaVirtualMachines/adoptopenjdk-12.jdk/Contents/Home",
          },
          {
            name = "JavaSE-11",
            path = "/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home",
          },
          {
            name = "JavaSE-8",
            path = "/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home/",
          }
        }
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath "config" .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },

    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
      importOrder = {
        "java",
        "javax",
        "com",
        "org"
      },
    },
    extendedClientCapabilities = extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },

  flags = {
    allow_incremental_sync = true,
  },
  init_options = {
    bundles = {},
  }
}

config['on_attach'] = function(client, bufnr)
  require'keymaps'.map_java_keys(bufnr);
  require "lsp_signature".on_attach({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    floating_window_above_cur_line = false,
    padding = '',
    handler_opts = {
      border = "rounded"
    }
  }, bufnr)
end

-- vim.api.nvim_echo({{vim.inspect(config.cmd), "Normal"}}, true, {})

-- local log_file = io.open("/tmp/my_log_file.txt", "a")
-- log_file:write(vim.inspect(config.cmd) .. "\n")
-- log_file:close()

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)


