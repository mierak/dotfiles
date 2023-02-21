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
	},
	pickers = {
		find_files = {
			find_command = { "fd", "--strip-cwd-prefix", "--type", "f" },
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- even more opts
			}),
		},
	},
})

require("telescope").load_extension("ui-select")
