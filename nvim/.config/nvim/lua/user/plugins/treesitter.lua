return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewfile" }, -- when a new or existing file gets opened
  build = ":TSUpdate", -- run this whenever this plugin gets installed or updated 
  dependencies = {
    "windwp/nvim-ts-autotag",
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
        "python"
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
