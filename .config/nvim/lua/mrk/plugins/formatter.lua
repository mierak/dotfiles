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
				astro = {
					require("formatter.defaults.prettier"),
				},
				markdown = {
					require("formatter.defaults.prettier"),
				},
				css = {
					require("formatter.filetypes.css").prettier,
				},
				scss = {
					require("formatter.filetypes.css").prettier,
				},
				json = {
					require("formatter.filetypes.json").prettier,
				},
				jsonc = {
					require("formatter.filetypes.json").prettier,
				},
				rust = {
					require("formatter.filetypes.rust").rustfmt,
				},
				c = {
					require("formatter.filetypes.c").clangformat,
				},
				sh = {
					require("formatter.filetypes.sh").shfmt,
				},
			},
		}
	end,
}
