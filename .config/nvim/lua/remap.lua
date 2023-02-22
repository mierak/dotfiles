vim.g.mapleader = " "

-- Move selected
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Kep cursor in the middle when jumping around
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Convenience to to yank to plus register
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Tab navigation
vim.keymap.set("n", "<C-l>", "<cmd>BufferLineCycleNext<cr>")
vim.keymap.set("n", "<C-h>", "<cmd>BufferLineCyclePrev<cr>")
vim.keymap.set("n", "<C-w><C-w>", "<cmd>tabclose<cr>")

-- Nerd Tree
vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFocus<cr>")

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<C-e>", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>fo", "<cmd>Telescope treesitter<cr>")

vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<cr>")

-- Snippets
local ls = require("luasnip")
-- Move to the next item within snippet
vim.keymap.set({ "i", "s" }, "<C-k>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })
-- Move to the previous item within snippet
vim.keymap.set({ "i", "s" }, "<c-j>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })

-- Disallow movement with arrow keys
vim.keymap.set("n", "<Up>", "<NOP>")
vim.keymap.set("n", "<Down>", "<NOP>")
vim.keymap.set("n", "<Left>", "<NOP>")
vim.keymap.set("n", "<Right>", "<NOP>")
vim.keymap.set("i", "<Up>", "<NOP>")
vim.keymap.set("i", "<Down>", "<NOP>")
vim.keymap.set("i", "<Left>", "<NOP>")
vim.keymap.set("i", "<Right>", "<NOP>")

-- Formatting
vim.keymap.set("n", "<leader><C-f>", "<cmd>Format<cr>")
