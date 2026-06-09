return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		opts = {
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		},
		config = function(_, _opts)
			vim.filetype.add({
				pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
			})
			vim.filetype.add({
				pattern = { ["%..*%rc"] = "jsonc" },
			})
			vim.filetype.add({
				pattern = { [".*%.mdx"] = "markdown" },
			})
			vim.filetype.add({
				pattern = { [".*local/share/chezmoi.*modify_.*"] = "bash" },
			})
			vim.filetype.add({
				pattern = { [".*%.config/shell/.*"] = "bash" },
			})

			local ts = require("nvim-treesitter")
			local langs = {
				"rust",
				"ron",
				"lua",
				"typescript",
				"javascript",
				"json",
				"html",
				"bash",
				"yaml",
				"gitignore",
				"css",
				"markdown_inline",
			}
			for _, lang in ipairs(langs) do
				ts.install(lang)
			end

			-- Not every tree-sitter parser is the same as the file type detected
			-- So the patterns need to be registered more cleverly
			local patterns = {}
			for _, lang in ipairs(langs) do
				local lang_pat = vim.treesitter.language.get_filetypes(lang)
				for _, pp in pairs(lang_pat) do
					table.insert(patterns, pp)
				end
			end

			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[0][0].foldmethod = "expr"

			vim.api.nvim_create_autocmd("FileType", {
				pattern = patterns,
				callback = function()
					vim.treesitter.start()
				end,
			})

			ts.setup(_opts)
		end,
	},
	{
		"luckasRanarison/tree-sitter-hypr",
	},
}
