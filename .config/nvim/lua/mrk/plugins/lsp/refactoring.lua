return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-treesitter/nvim-treesitter" },
	},
	opts = function()
		vim.api.nvim_set_keymap(
			"v",
			"<leader>rr",
			"<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
			{ noremap = true }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>rv",
			":lua require('refactoring').debug.print_var({ normal = true })<CR>",
			{ noremap = true }
		)

		return {
			print_var_statements = {
				lua = {
					'print("DEBUG:%s", %s)',
				},
			},
		}
	end,
}
