return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "lua", "typescript", "javascript", "json", "html", "bash", "yaml", "gitignore", "css" },
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		},
		config = function(_, opts)
			vim.filetype.add({
				pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
			})
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	-- {
	-- 	"nvim-treesitter/nvim-treesitter-context",
	-- },
	{
		"luckasRanarison/tree-sitter-hypr",
	},
}
