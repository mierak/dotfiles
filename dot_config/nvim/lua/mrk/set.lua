vim.o.termguicolors = true
vim.o.wrap = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.timeoutlen = 500
vim.o.title = true
vim.o.scrolloff = 6
vim.o.sidescrolloff = 10
vim.o.cursorline = true
vim.o.cmdheight = 1
vim.o.breakindent = true

vim.o.wildmode = "longest,list,full"

vim.o.fillchars = "eob: ,vert:│"

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.smartcase = true
vim.o.ignorecase = true

if vim.env.TMUX ~= nil then
	local copy = { "tmux", "load-buffer", "-w", "-" }
	local paste = { "bash", "-c", "tmux refresh-client -l && sleep 0.05 && tmux save-buffer -" }
	vim.g.clipboard = {
		name = "tmux",
		copy = {
			["+"] = copy,
			["*"] = copy,
		},
		paste = {
			["+"] = paste,
			["*"] = paste,
		},
		cache_enabled = 0,
	}
else
	vim.g.clipboard = "osc52"
end
