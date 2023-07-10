local group = vim.api.nvim_create_augroup("Restart", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = vim.env.HOME .. "/.config/sxhkd/sxhkdrc",
	group = group,
	callback = function()
		io.popen("killall sxhkd && sxhkd & disown")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = vim.env.HOME .. "/.config/dunst/dunstrc",
	group = group,
	callback = function()
		io.popen("killall dunst && dunst & disown")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	group = group,
	callback = function()
		vim.opt_local.formatoptions = "jql"
	end,
})

-- Set colorscheme delayed
--vim.api.nvim_create_autocmd("ColorScheme", {
--	pattern = "*",
--	group = group,
--	callback = function()
--		-- Completion colors
--		vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#808080" })
--
--		vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#569CD6" })
--		vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpItemAbbrMatch" })
--
--		vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#9CDCFE" })
--		vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
--		vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
--
--		vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#C586C0" })
--		vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
--
--		vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#D4D4D4" })
--		vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
--		vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })
--
--        local nvimtree_bg = "#1b2027"
--        vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = nvimtree_bg })
--        vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = nvimtree_bg })
--        vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = nvimtree_bg })
--	end,
--})
