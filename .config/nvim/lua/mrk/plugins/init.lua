return {
	"github/copilot.vim",
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
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({})
			require("neoscroll.config").set_mappings({
				["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100" } },
				["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } },
			})
		end,
	},
}
