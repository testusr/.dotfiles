-- having a fat cursor instead of a thin one
vim.opt.guicursor = ""

-- line numbers and relative line numbers 
vim.opt.nu = true
vim.opt.rnu = true


-- line intendation 4 spaces 
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- no line wrapping 
vim.opt.wrap = false

-- dont have backups and swap files but a persistent
-- long history for undo tree
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- switch off highlighting of all search findings 
vim.opt.hlsearch = false
-- highlight extensions like wild cards etc / in editor evaluation 
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- keep at least 8 lines at the end of the window when scrolling down
-- instead of being at the end of the file 
vim.opt.scrolloff = 8

vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.g.mapleader = " "
