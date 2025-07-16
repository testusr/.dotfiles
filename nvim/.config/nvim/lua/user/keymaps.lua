vim.g.mapleader = " " -- setting the leader key

local keymap = vim.keymap -- for conciseness

-- Function to open URLs or files in the default application
local function open_external(file)
    local sysname = vim.loop.os_uname().sysname:lower()
    local jobcmd
    if sysname:match("windows") then
        jobcmd = {"cmd.exe", "/c", "start", file}
    elseif sysname:match("darwin") then
        jobcmd = {"open", file}
    else
        jobcmd = {"xdg-open", file}
    end
    local job = vim.fn.jobstart(jobcmd, { detach = true })
    vim.defer_fn(function() vim.fn.jobstop(job) end, 5000)
end

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Reload Neovim config
keymap.set("n", "<leader>ss", ":source %<CR>", { desc = "Reload neovim config" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>=", "<C-w>=", { desc = "Make split equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tabs
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tg", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Paste from clipboard
keymap.set("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })

-- Open URL under cursor in default browser
keymap.set("n", "<leader>u", function()
    open_external(vim.fn.expand("<cfile>"))
end, { desc = "Open URL under cursor" })
