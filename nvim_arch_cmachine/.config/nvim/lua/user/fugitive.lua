local status_ok, comment = pcall(require, "fugitive")
if not status_ok then
  return
end

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

keymap("n", "<leader>gs", vim.cmd.Git);
