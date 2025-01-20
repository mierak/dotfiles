local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("mrk")

if vim.g.neovide then
	-- Put anything you want to happen only in Neovide here
	vim.o.guifont = "VictorMono NF:h13" -- text below applies for VimScript
	vim.g.neovide_refresh_rate = 144
	vim.g.neovide_refresh_rate_idle = 5

	vim.keymap.set("v", "<C-S-c>", '"+y') -- Copy
	vim.keymap.set("n", "<C-S-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<C-S-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<C-S-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<C-S-v>", '<ESC>l"+Pli') -- Paste insert mode

	vim.g.neovide_scale_factor = 1.0
	local change_scale_factor = function(delta)
		vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
	end
	vim.keymap.set("n", "<C-+>", function()
		change_scale_factor(1.25)
	end)
	vim.keymap.set("n", "<C-->", function()
		change_scale_factor(1 / 1.25)
	end)
end
