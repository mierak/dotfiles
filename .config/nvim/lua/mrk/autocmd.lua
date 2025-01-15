local group = vim.api.nvim_create_augroup("Restart", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	group = group,
	callback = function()
		vim.opt_local.formatoptions = "jql"
	end,
})

-- Highlight after yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})
