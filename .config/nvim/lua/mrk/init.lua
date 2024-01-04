vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "

require("lazy").setup("mrk.plugins")
require("mrk.remap")
require("mrk.set")
require("mrk.autocmd")
require("mrk.globals")
require("mrk.colors")
