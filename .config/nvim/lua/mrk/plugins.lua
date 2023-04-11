return {
	-- Autocomplete plugins,
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-nvim-lsp-signature-help",
	"saadparwaiz1/cmp_luasnip",
	"L3MON4D3/LuaSnip",
	"windwp/nvim-autopairs",
	"mhartington/formatter.nvim",
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	},
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	"neovim/nvim-lspconfig",
	"numToStr/Comment.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	},

	-- telescope and exts
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	"nvim-telescope/telescope-ui-select.nvim",

	"mbbill/undotree",
	"stevearc/aerial.nvim",

	-- UI,
	"nvim-tree/nvim-web-devicons",
	"b0o/incline.nvim",
	"lukas-reineke/indent-blankline.nvim",
	"petertriho/nvim-scrollbar",
	"lewis6991/gitsigns.nvim",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
	},

	-- Colors
	"NTBBloodbath/doom-one.nvim",
	--"olimorris/onedarkpro.nvim"
	"navarasu/onedark.nvim",
	"norcalli/nvim-colorizer.lua",

	"folke/which-key.nvim",
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
	"ThePrimeagen/vim-be-good",
}