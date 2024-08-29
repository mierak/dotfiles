-- return {
-- 	"petertriho/nvim-scrollbar",
-- 	opts = {
-- 		show = true,
-- 		show_in_active_only = true,
-- 		handlers = {
-- 			cursor = true,
-- 			diagnostic = false,
-- 			gitsigns = true, -- Requires gitsigns
-- 			handle = true,
-- 			search = false, -- Requires hlslens
-- 			ale = false, -- Requires ALE
-- 		},
-- 		marks = {
-- 			Cursor = {
-- 				text = "",
-- 				priority = 0,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "Normal",
-- 			},
-- 			Search = {
-- 				text = { "-", "=" },
-- 				priority = 1,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "Search",
-- 			},
-- 			Error = {
-- 				text = { "-", "" },
-- 				priority = 2,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "DiagnosticVirtualTextError",
-- 			},
-- 			Warn = {
-- 				text = { "-", "" },
-- 				priority = 3,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "DiagnosticVirtualTextWarn",
-- 			},
-- 			Info = {
-- 				text = { "-", "=" },
-- 				priority = 4,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "DiagnosticVirtualTextInfo",
-- 			},
-- 			Hint = {
-- 				text = { "-", "=" },
-- 				priority = 5,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "DiagnosticVirtualTextHint",
-- 			},
-- 			Misc = {
-- 				text = { "-", "=" },
-- 				priority = 6,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "Normal",
-- 			},
-- 			GitAdd = {
-- 				text = "┆",
-- 				priority = 7,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "GitSignsAdd",
-- 			},
-- 			GitChange = {
-- 				text = "┆",
-- 				priority = 7,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "GitSignsChange",
-- 			},
-- 			GitDelete = {
-- 				text = "▁",
-- 				priority = 7,
-- 				gui = nil,
-- 				color = nil,
-- 				cterm = nil,
-- 				color_nr = nil, -- cterm
-- 				highlight = "GitSignsDelete",
-- 			},
-- 		},
-- 		excluded_buftypes = {
-- 			"terminal",
-- 		},
-- 		excluded_filetypes = {
-- 			"prompt",
-- 			"TelescopePrompt",
-- 			"noice",
-- 		},
-- 	},
-- }

---@module "neominimap.config.meta"
return {
	"Isrothy/neominimap.nvim",
	enabled = false,
	lazy = false, -- NOTE: NO NEED to Lazy load
	-- Optional
	keys = {
		{ "<leader>nt", "<cmd>Neominimap toggle<cr>", desc = "Toggle minimap" },
		{ "<leader>no", "<cmd>Neominimap on<cr>", desc = "Enable minimap" },
		{ "<leader>nc", "<cmd>Neominimap off<cr>", desc = "Disable minimap" },
		{ "<leader>nf", "<cmd>Neominimap focus<cr>", desc = "Focus on minimap" },
		{ "<leader>nu", "<cmd>Neominimap unfocus<cr>", desc = "Unfocus minimap" },
		{ "<leader>ns", "<cmd>Neominimap toggleFocus<cr>", desc = "Toggle focus on minimap" },
		{ "<leader>nwt", "<cmd>Neominimap winToggle<cr>", desc = "Toggle minimap for current window" },
		{ "<leader>nwr", "<cmd>Neominimap winRefresh<cr>", desc = "Refresh minimap for current window" },
		{ "<leader>nwo", "<cmd>Neominimap winOn<cr>", desc = "Enable minimap for current window" },
		{ "<leader>nwc", "<cmd>Neominimap winOff<cr>", desc = "Disable minimap for current window" },
		{ "<leader>nbt", "<cmd>Neominimap bufToggle<cr>", desc = "Toggle minimap for current buffer" },
		{ "<leader>nbr", "<cmd>Neominimap bufRefresh<cr>", desc = "Refresh minimap for current buffer" },
		{ "<leader>nbo", "<cmd>Neominimap bufOn<cr>", desc = "Enable minimap for current buffer" },
		{ "<leader>nbc", "<cmd>Neominimap bufOff<cr>", desc = "Disable minimap for current buffer" },
	},
	init = function()
		vim.opt.wrap = false -- Recommended
		vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
		---@type Neominimap.UserConfig
		vim.g.neominimap = {
			auto_enable = true,
			x_multiplier = 8,
			y_multiplier = 1,
			layout = "split",
			float = {
				fix_width = true,
				minimap_width = 10,
				window_border = "none",
			},
			split = {
				fix_width = true,
				minimap_width = 10,
				window_border = "none",
			},
		}
	end,
}
