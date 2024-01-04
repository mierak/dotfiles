return {
	"mhartington/formatter.nvim",
	opts = function()
		return {
			logging = true,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				javascript = {
					require("formatter.filetypes.javascript").prettier,
				},
				javascriptreact = {
					require("formatter.filetypes.javascriptreact").prettier,
				},
				typescript = {
					require("formatter.filetypes.typescript").prettier,
				},
				typescriptreact = {
					require("formatter.filetypes.typescriptreact").prettier,
				},
				rust = {
					require("formatter.filetypes.rust").rustfmt,
				},
				c = {
					require("formatter.filetypes.c").clangformat,
				},
			},
		}
	end,
}
