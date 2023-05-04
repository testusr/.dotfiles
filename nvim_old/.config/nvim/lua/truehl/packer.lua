-- This file can be loaded by calling `lua require('plugins')` from your init.vim
--print("hello from packer")

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- telescope fuzzy finder 
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) --deep
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

    -- colorscheme 
    use({ 'rose-pine/neovim', as = 'rose-pine' })
    vim.cmd('colorscheme rose-pine')

    -- harpoon
    use('theprimeagen/harpoon')

    -- tmux & split window navigation
    use("christoomey/vim-tmux-navigator") -- enaables splitscreen navigation between splits via CTRL+jklh

    -- commenting with gc
    use("numToStr/Comment.nvim") -- commeting one or several lines with gcc or gc<num>j


    -- undotree 
    use('mbbill/undotree')
    use('tpope/vim-fugitive')

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {                                      -- Optional
            'williamboman/mason.nvim',
            run = function()
                pcall(vim.cmd, 'MasonUpdate')
            end,
        },
        {'williamboman/mason-lspconfig.nvim'}, -- Optional

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},     -- Required
        {'hrsh7th/cmp-nvim-lsp'}, -- Required
        {'L3MON4D3/LuaSnip'},     -- Required
    }
}
-- java language server integrations (eclipse)
use("mfussenegger/nvim-jdtls")
use({"glepnir/lspsaga.nvim", branch = "main"})

-- markdown preview 
use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
})
use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })

end)
