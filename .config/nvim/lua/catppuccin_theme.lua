vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

require("catppuccin").setup({
	transparent_background = true,
	term_colors = true,
})

vim.cmd [[colorscheme catppuccin]]
