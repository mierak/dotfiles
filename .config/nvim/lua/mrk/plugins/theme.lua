--- @type "tokyonight" | "onedark" | "catppuccin" | "kanagawa"
local theme = "kanagawa"

local function set_cmp_kind_hl()
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
end

if theme == "onedark" then
	return {
		"navarasu/onedark.nvim",
		opts = {
			transparent = true,
			style = "warm",
			toggle_style_key = "<leader>ts",
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
		},
		config = function(_, opts)
			require("onedark").setup(opts)
			require("onedark").load()

			set_cmp_kind_hl()

			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#262a36" })

			-- harpoon tabline
			-- vim.api.nvim_set_hl(0, "HarpoonInactive", { fg = "#63698c" })
			-- vim.api.nvim_set_hl(0, "HarpoonActive", { fg = "white" })
			-- vim.api.nvim_set_hl(0, "HarpoonNumberActive", { fg = "#7aa2f7" })
			-- vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { fg = "#7aa2f7" })
			-- vim.api.nvim_set_hl(0, "TabLineFill", { fg = "white" })
		end,
	}
elseif theme == "tokyonight" then
	return {
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = true,
			styles = {
				sidebars = "dark",
				floats = "dark",
			},
			sidebars = { "nvim-tree" },
			plugins = { auto = true },
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
			set_cmp_kind_hl()
		end,
	}
elseif theme == "catppuccin" then
	return {
		"catppuccin/nvim",
		priority = 1000,
		opts = { flavour = "macchiato" },
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
			set_cmp_kind_hl()
		end,
	}
elseif theme == "kanagawa" then
	return {
		"rebelot/kanagawa.nvim",
		priority = 1000,
		opts = {
			compile = false, -- enable compiling the colorscheme
			undercurl = true, -- enable undercurls
			commentStyle = { italic = true },
			functionStyle = {},
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			typeStyle = {},
			transparent = false, -- do not set background color
			dimInactive = false, -- dim inactive window `:h hl-NormalNC`
			terminalColors = true, -- define vim.g.terminal_color_{0,17}
			colors = { -- add/modify theme and palette colors
				palette = {},
				theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
			},
			overrides = function(colors) -- add/modify highlights
				return {}
			end,
			theme = "wave", -- Load "wave" theme when 'background' option is not set
			background = { -- map the value of 'background' option to a theme
				dark = "wave", -- try "dragon" !
				light = "wave",
			},
		},
		init = function()
			vim.cmd("colorscheme kanagawa")
			set_cmp_kind_hl()
		end,
	}
end
