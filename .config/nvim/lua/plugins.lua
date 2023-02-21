return require('packer').startup(function (use)
    use 'wbthomason/packer.nvim'
    -- Autocomplete plugins
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'
    use 'windwp/nvim-autopairs'
    use 'mhartington/formatter.nvim'

    use 'neovim/nvim-lspconfig'
    use 'numToStr/Comment.nvim'
    use 'nvim-telescope/telescope-ui-select.nvim'

    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use 'folke/which-key.nvim'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'
    use 'NTBBloodbath/doom-one.nvim'
    use 'airblade/vim-gitgutter'
    use 'norcalli/nvim-colorizer.lua'
    --use {
    --    'akinsho/bufferline.nvim',
    --    requires = { 'kyazdani42/nvim-web-devicons' }
    --}
    use 'lukas-reineke/indent-blankline.nvim'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use 'stevearc/aerial.nvim'
    use 'petertriho/nvim-scrollbar'
    use 'mbbill/undotree'
end)
