
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
	open_on_tab = true,
	filters = {
		custom = { "^.git$", "^.github$", "^node_modules" }
	},
})

