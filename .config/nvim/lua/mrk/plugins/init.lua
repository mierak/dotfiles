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
				["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "80" } },
				["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "80" } },
				["<C-b>"] = { "scroll", { "-vim.fn.winheight(0)", "true", "100" } },
				["<C-f>"] = { "scroll", { "vim.fn.winheight(0)", "true", "100" } },
			})
		end,
	},
	{
		-- FIXME hello
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			require("mini.hipatterns").setup({
				highlighters = {
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
				},
			})
		end,
	},
}
