return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night", -- or "storm", "day" depending on your preference
      transparent = false, -- set to true if you want a transparent background
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      on_colors = function(colors)
        colors.bg = "#000000" -- set true black background
      end,
    })
    vim.cmd("colorscheme tokyonight")
  end
}
