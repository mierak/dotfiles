vim.cmd("colorscheme onedark")
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

vim.api.nvim_set_hl(0, "CursorLine", { bg = "#262a36" })

-- harpoon tabline
vim.api.nvim_set_hl(0, "HarpoonInactive", { fg = "#63698c" })
vim.api.nvim_set_hl(0, "HarpoonActive", { fg = "white" })
vim.api.nvim_set_hl(0, "HarpoonNumberActive", { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { fg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = "white" })
