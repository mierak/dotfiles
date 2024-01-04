return {
	"github/copilot.vim",
	"navarasu/onedark.nvim",
	"christoomey/vim-tmux-navigator",

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
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		requires = { { "nvim-lua/plenary.nvim" } },
	},

	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({})
			local t = {}
			t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100" } }
			t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } }
			require("neoscroll.config").set_mappings(t)
		end,
	},
}
