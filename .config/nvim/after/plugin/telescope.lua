local trouble = require("trouble.providers.telescope")

require("telescope").setup({
	defaults = {
		path_display = { "smart" },
		sorting_strategy = "ascending",
		layout_config = {
			width = 0.90,
			height = 0.95,
			horizontal = {
				prompt_position = "top",
				preview_cutoff = 60,
				preview_width = 0.7,
			},
		},
		mappings = {
			i = { ["<c-t>"] = trouble.open_with_trouble },
			n = { ["<c-t>"] = trouble.open_with_trouble },
		},
	},
	pickers = {
		find_files = {
			--find_command = { "fd", "--strip-cwd-prefix", "--type", "f" },
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- even more opts
			}),
		},
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
})

require("telescope").load_extension("ui-select")
require('telescope').load_extension('fzf')
require('telescope').load_extension('harpoon')
