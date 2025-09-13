return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
      "ibhagwan/fzf-lua",
      "echasnovski/mini.pick",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<CR>", desc = "Open Neogit" },
    },

    -- Only enable if we're inside a git repo
    cond = function()
      vim.fn.system("git rev-parse --is-inside-work-tree")
      return vim.v.shell_error == 0
    end,

    config = function()
      local neogit = require("neogit")
      neogit.setup({
        integrations = {
          diffview = true,
        },
        signs = {
          section = { ">", "v" },
          item = { ">", "v" },
        },
        disable_commit_confirmation = false,
        auto_refresh = true,
      })

      local wk = require("which-key")
      wk.register({
        gn = { "<cmd>Neogit<CR>", "Open Neogit" },
      }, {
        prefix = "<leader>",
        mode = "n",
        silent = true,
        noremap = true,
        nowait = true,
      })
    end,
  },
}

