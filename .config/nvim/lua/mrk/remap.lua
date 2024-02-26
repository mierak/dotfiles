-- Move selected
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Kep cursor in the middle when jumping around
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("i", "<C-c>", "<Plug>(copilot-dismiss)<C-c>")

-- Convenience to to yank to plus register
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])
vim.keymap.set("n", "<leader>P", [["+P]])

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Nvim Tree
vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFocus<cr>")

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("v", "<leader>fw", builtin.grep_string)
vim.keymap.set("n", "<leader>fw", function()
	builtin.grep_string({ search = vim.fn.expand("<cword>") })
end)

vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
-- vim.keymap.set("n", "<C-e>", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>fo", "<cmd>Telescope treesitter<cr>")

vim.keymap.set("n", "<leader>ut", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>uf", vim.cmd.UndotreeFocus)

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

vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>")

vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<CR>")
