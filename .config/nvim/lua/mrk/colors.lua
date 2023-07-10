--require("onedarkpro").setup({
--	colors = {
--		onedark = {
--			bg = "#1e222a",
--		},
--	},
--	styles = {
--		types = "NONE",
--		methods = "NONE",
--		numbers = "NONE",
--		strings = "NONE",
--		comments = "italic",
--		keywords = "NONE",
--		constants = "NONE",
--		functions = "NONE",
--		operators = "NONE",
--		variables = "NONE",
--		parameters = "NONE",
--		conditionals = "italic",
--		virtual_text = "NONE",
--	},
--	options = {
--		highlight_inactive_windows = false,
--	},
--})

local doom = require("doom-one.colors")
doom.dark.bg = "#1e222a"

vim.g.doom_one_cursor_coloring = false
-- Set :terminal colors
vim.g.doom_one_terminal_colors = true
-- Enable italic comments
vim.g.doom_one_italic_comments = false
-- Enable TS support
vim.g.doom_one_enable_treesitter = true
-- Color whole diagnostic text or only underline
vim.g.doom_one_diagnostics_text_color = false
-- Enable transparent background
vim.g.doom_one_transparent_background = false

-- Pumblend transparency
vim.g.doom_one_pumblend_enable = false
vim.g.doom_one_pumblend_transparency = 20

-- Plugins integration
vim.g.doom_one_plugin_neorg = false
vim.g.doom_one_plugin_barbar = false
vim.g.doom_one_plugin_telescope = true
vim.g.doom_one_plugin_neogit = true
vim.g.doom_one_plugin_nvim_tree = true
vim.g.doom_one_plugin_dashboard = true
vim.g.doom_one_plugin_startify = true
vim.g.doom_one_plugin_whichkey = true
vim.g.doom_one_plugin_indent_blankline = true
vim.g.doom_one_plugin_vim_illuminate = true
vim.g.doom_one_plugin_lspsaga = false

--vim.cmd("colorscheme onedark")
local od = require("onedark")
od.setup({
	style = "warm",
	colors = {
		bg0 = "#1e222a",
		bg1 = "#1e222a",
		bg_d = "#1c1f27",
	},
	code_style = {
		comments = "italic",
		keywords = "none",
		functions = "italic,bold",
		strings = "none",
		variables = "none",
	},
	diagnostics = {
		darker = false,
		undercurl = true,
		background = false,
	},
	lualine = {
		transparent = false,
	},
	highlights = {
		IndentBlanklineChar = { fg = "$bg2", fmt = "nocombine" },
		IndentBlanklineContextChar = { fg = "$purple", fmt = "nocombine" },
		IndentBlanklineContextStart = { sp = "$purple", fmt = "nocombine,underline" },
	},
})
require("onedark").load()

vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#808080" })

vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#569CD6" })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpItemAbbrMatch" })

vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#9CDCFE" })
vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })

vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#C586C0" })
vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })

vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#D4D4D4" })
vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })

--local nvimtree_bg = "#1c1f27"
--vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = nvimtree_bg })
--vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = nvimtree_bg })
--vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = nvimtree_bg })

vim.api.nvim_set_hl(0, "CursorLine", { bg = "#262a36" })

-- harpoon tabline
vim.api.nvim_set_hl(0, "HarpoonInactive", { fg = "#63698c" })
vim.api.nvim_set_hl(0, "HarpoonActive", { fg = "white" })
vim.api.nvim_set_hl(0, "HarpoonNumberActive", { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = "white" })
